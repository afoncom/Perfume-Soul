import Fluent
import Vapor

actor PerfumeProfileCache {
    private var profilesByLanguage: [String: [PerfumeProfile]] = [:]

    func profiles(
        on database: any Database,
        language: String? = nil
    ) async throws -> [PerfumeProfile] {
        let languageKey = PerfumeNotesLoader.prefersEnglish(acceptLanguage: language) ? "en" : "ru"
        if let cachedProfiles = profilesByLanguage[languageKey] {
            return cachedProfiles
        }

        let perfumeModels = try await PerfumeModel.query(on: database)
            .withPerfumeProfileFields()
            .with(\.$brand)
            .with(\.$notes) { query in
                query.with(\.$note)
            }
            .with(\.$accords) { query in
                query.with(\.$accord)
            }
            .all()
        let profiles = perfumeModels.compactMap {
            PerfumeProfile(model: $0, language: language)
        }
        profilesByLanguage[languageKey] = profiles
        return profiles
    }

    func invalidate() {
        profilesByLanguage = [:]
    }
}

private struct PerfumeProfileCacheKey: StorageKey {
    typealias Value = PerfumeProfileCache
}

extension Application {
    var perfumeProfileCache: PerfumeProfileCache {
        if let cache = storage[PerfumeProfileCacheKey.self] {
            return cache
        }

        let cache = PerfumeProfileCache()
        storage[PerfumeProfileCacheKey.self] = cache
        return cache
    }
}
