import Fluent

struct PerfumeryHistoryItem: Codable, Equatable {
    let publicationDate: String
    let eventYear: Int
    let title: String
    let fullStory: String
}

enum PerfumeryHistoryLoader {
    static func load(
        dateKey: String,
        language: String?,
        on database: any Database
    ) async throws -> PerfumeryHistoryItem? {
        let query = PerfumeryHistoryModel.query(on: database)
            .filter(\.$dateKey == dateKey)
        guard let model = try await query.first() else {
            return nil
        }

        let isRussian = language?.lowercased().hasPrefix("ru") == true
        return PerfumeryHistoryItem(
            publicationDate: model.dateKey,
            eventYear: model.eventYear,
            title: isRussian ? model.titleRu : model.titleEn,
            fullStory: isRussian ? model.fullStoryRu : model.fullStoryEn
        )
    }
}
