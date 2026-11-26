import Foundation

struct QuizCalendarDay: Codable, Sendable {
    let dayKey: String
    let questionIDs: [Int]
}

enum QuizCalendar {
    private struct CalendarResource: Decodable {
        let schemaVersion: Int
        let days: [QuizCalendarDay]
    }

    static func load() throws -> [QuizCalendarDay] {
        guard let url = Bundle.module.url(forResource: "quiz-calendar", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let resource = try JSONDecoder().decode(CalendarResource.self, from: Data(contentsOf: url))
        guard resource.schemaVersion == 1,
            !resource.days.isEmpty,
            Set(resource.days.map(\.dayKey)).count == resource.days.count,
            resource.days.allSatisfy({ isValidDayKey($0.dayKey) && $0.questionIDs.count == 15 && Set($0.questionIDs).count == 15 }) else {
            throw CocoaError(.coderReadCorrupt)
        }
        return resource.days
    }

    static func isValidDayKey(_ value: String) -> Bool {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let date = formatter.date(from: value) else {
            return false
        }
        return formatter.string(from: date) == value
    }
}
