import Foundation

protocol PersonalPerfumeTopStorage {
    func loadPerfumeIDs() -> [Int]
    func savePerfumeIDs(_ perfumeIDs: [Int])
    func clear()
}

final class PersonalPerfumeTopStorageImpl {
    private let userDefaults: UserDefaults
    private let key = "personalPerfume.topIDs"

    init(userDefaults: UserDefaults) { self.userDefaults = userDefaults }
}

extension PersonalPerfumeTopStorageImpl: PersonalPerfumeTopStorage {
    func loadPerfumeIDs() -> [Int] { userDefaults.array(forKey: key) as? [Int] ?? [] }
    func savePerfumeIDs(_ perfumeIDs: [Int]) { userDefaults.set(perfumeIDs, forKey: key) }
    func clear() { userDefaults.removeObject(forKey: key) }
}
