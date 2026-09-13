import Fluent
import Vapor

enum PerfumeProfileCacheExpiration {
    static func isExpired(createdAt: Date, ttl: TimeInterval, now: Date = .now) -> Bool {
        now.timeIntervalSince(createdAt) >= ttl
    }
}

actor PerfumeProfileCache {
    private struct Entry {
        let profiles: [PerfumeProfile]
        let createdAt: Date
    }

    private let ttl: TimeInterval
    private var profilesByLanguage: [String: Entry] = [:]
    private var loadingTasks: [String: Task<[PerfumeProfile], any Error>] = [:]

    init(ttl: TimeInterval = 300) {
        self.ttl = ttl
    }

    func profiles(
        on database: any Database,
        language: String? = nil
    ) async throws -> [PerfumeProfile] {
        let languageKey = PerfumeNotesLoader.prefersEnglish(acceptLanguage: language) ? "en" : "ru"
        if let entry = profilesByLanguage[languageKey],
           !PerfumeProfileCacheExpiration.isExpired(createdAt: entry.createdAt, ttl: ttl) {
            return entry.profiles
        }
        if let loadingTask = loadingTasks[languageKey] {
            return try await loadingTask.value
        }

        let loadingTask = Task { [database] in
            let perfumeModels = try await PerfumeModel.query(on: database)
                .withPerfumeProfileFields()
                .with(\.$brand)
                .with(\.$notes) { query in query.with(\.$note) }
                .with(\.$accords) { query in query.with(\.$accord) }
                .all()
            return perfumeModels.compactMap { PerfumeProfile(model: $0, language: language) }
        }
        loadingTasks[languageKey] = loadingTask
        defer { loadingTasks[languageKey] = nil }
        let profiles = try await loadingTask.value
        profilesByLanguage[languageKey] = Entry(profiles: profiles, createdAt: .now)
        return profiles
    }

    func invalidate() {
        profilesByLanguage = [:]
        loadingTasks = [:]
    }
}

private struct PerfumeProfileCacheKey: StorageKey {
    typealias Value = PerfumeProfileCache
}

extension Application {
    var perfumeProfileCache: PerfumeProfileCache {
        guard let cache = storage[PerfumeProfileCacheKey.self] else {
            fatalError("PerfumeProfileCache must be configured before use.")
        }
        return cache
    }

    func configurePerfumeProfileCache() {
        storage[PerfumeProfileCacheKey.self] = PerfumeProfileCache()
    }
}
