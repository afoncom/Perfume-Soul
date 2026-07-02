import Fluent

struct DailyHoroscope: Codable, Equatable {
    let sign: String
    let energyOfDay: String
}

enum DailyHoroscopeLoader {
    static func load(on database: any Database) async throws -> [DailyHoroscope] {
        let horoscopes = try await DailyHoroscopeModel.query(on: database)
            .sort(\.$sortOrder)
            .all()

        return horoscopes.map(DailyHoroscope.init(model:))
    }
}

private extension DailyHoroscope {
    init(model: DailyHoroscopeModel) {
        self.sign = model.sign
        self.energyOfDay = model.energyOfDay
    }
}
