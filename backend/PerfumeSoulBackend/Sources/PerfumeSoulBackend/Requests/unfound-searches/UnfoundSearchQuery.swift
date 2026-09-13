import Fluent
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
        if let existing = try await UnfoundSearchQueryModel.query(on: database)
            .filter(\.$normalizedQuery == event.normalizedQuery)
            .filter(\.$searchContext == event.context.rawValue)
            .first() {
            existing.queryText = event.queryText
            existing.occurrenceCount += 1
            try await existing.update(on: database)
            return
        }

        try await UnfoundSearchQueryModel(
            queryText: event.queryText,
            normalizedQuery: event.normalizedQuery,
            searchContext: event.context.rawValue
        ).create(on: database)
    }
}

struct UnfoundSearchQueryResponse: Content {
    let accepted: Bool
}
