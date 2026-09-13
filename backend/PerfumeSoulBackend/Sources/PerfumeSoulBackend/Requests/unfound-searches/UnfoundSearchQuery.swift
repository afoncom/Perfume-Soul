import Fluent
import FluentSQL
import Foundation
import Vapor

struct UnfoundSearchQueryRequest: Content {
    let query: String
    let context: String

    func validatedEvent() throws -> UnfoundSearchQueryEvent {
        let queryText = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (3...120).contains(queryText.count) else {
            throw Abort(.badRequest, reason: "Search query must contain 3 to 120 characters.")
        }
        guard let context = UnfoundSearchContext(rawValue: context) else {
            throw Abort(.badRequest, reason: "Unsupported search context.")
        }

        let normalizedQuery = queryText
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .lowercased()
        guard !normalizedQuery.isEmpty else {
            throw Abort(.badRequest, reason: "Search query must not be empty.")
        }

        return UnfoundSearchQueryEvent(
            queryText: queryText,
            normalizedQuery: normalizedQuery,
            context: context
        )
    }
}

enum UnfoundSearchContext: String {
    case library
    case similarFinder = "similar_finder"
    case compare
}

struct UnfoundSearchQueryEvent {
    let queryText: String
    let normalizedQuery: String
    let context: UnfoundSearchContext
}

enum UnfoundSearchQueryLogger {
    static func record(_ event: UnfoundSearchQueryEvent, on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }
        try await sqlDatabase.raw("""
            INSERT INTO unfound_search_queries
                (query_text, normalized_query, search_context, occurrence_count, first_seen_at, last_seen_at)
            VALUES
                (\(bind: event.queryText), \(bind: event.normalizedQuery), \(bind: event.context.rawValue), 1, NOW(), NOW())
            ON CONFLICT (normalized_query, search_context)
            DO UPDATE SET
                query_text = EXCLUDED.query_text,
                occurrence_count = unfound_search_queries.occurrence_count + 1,
                last_seen_at = NOW()
            """).run()
    }
}

actor UnfoundSearchRateLimiter {
    private let dailyLimit = 100
    private var counts: [String: (day: Date, count: Int)] = [:]

    func allows(ipAddress: String, now: Date = .now) -> Bool {
        let day = Calendar.current.startOfDay(for: now)
        let current = counts[ipAddress]
        let count = current?.day == day ? current?.count ?? 0 : 0
        guard count < dailyLimit else { return false }
        counts[ipAddress] = (day, count + 1)
        return true
    }
}

private struct UnfoundSearchRateLimiterKey: StorageKey {
    typealias Value = UnfoundSearchRateLimiter
}

extension Application {
    var unfoundSearchRateLimiter: UnfoundSearchRateLimiter {
        guard let limiter = storage[UnfoundSearchRateLimiterKey.self] else {
            fatalError("UnfoundSearchRateLimiter must be configured before use.")
        }
        return limiter
    }

    func configureUnfoundSearchRateLimiter() {
        storage[UnfoundSearchRateLimiterKey.self] = UnfoundSearchRateLimiter()
    }
}

struct UnfoundSearchQueryResponse: Content {
    let accepted: Bool
}
