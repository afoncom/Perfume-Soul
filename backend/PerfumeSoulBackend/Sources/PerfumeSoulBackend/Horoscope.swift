import Foundation
import Vapor

struct DailyHoroscope: Content, Decodable {
    let sign: String
    let date: String
    let energyOfDay: EnergyOfDay
}

struct EnergyOfDay: Content, Decodable {
    let text: String
}

enum DailyHoroscopeLoader {
    static func load() throws -> DailyHoroscope {
        let url = Bundle.module.url(forResource: "daily-horoscope", withExtension: "json")!
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(DailyHoroscope.self, from: data)
    }
}
