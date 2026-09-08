import Foundation

struct RecommendedPerfumeState: Codable, Equatable {
    var perfumes: [DailyPerfumeSummary]
    var reservePerfumes: [DailyPerfumeSummary]
    var topPerfumeIDs: [Int]
    var profileCalculationCacheKey: String?
    var weekKey: String
    var resolvedExcludedPerfumeIDs: [Int]?
}

protocol RecommendedPerfumeStateStorage {
    func loadState() -> RecommendedPerfumeState?
    func saveState(_ state: RecommendedPerfumeState)
    func clearState()
}

final class RecommendedPerfumeStateStorageImpl: RecommendedPerfumeStateStorage {
    private let userDefaults: UserDefaults
    private let key = "recommendedPerfume.state"

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func loadState() -> RecommendedPerfumeState? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(RecommendedPerfumeState.self, from: data)
    }

    func saveState(_ state: RecommendedPerfumeState) {
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }
        userDefaults.set(data, forKey: key)
    }

    func clearState() {
        userDefaults.removeObject(forKey: key)
    }
}
