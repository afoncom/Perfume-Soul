import Fluent

struct PerfumeryHistoryItem: Codable, Equatable {
    let publicationDate: String
    let eventYear: Int
    let title: String
    let fullStory: String
}

struct LegacyPerfumeryHistoryItem: Codable, Equatable {
    let year: Int
    let perfumeName: String
    let shortStory: String
    let fullStory: String
    let imageUrl: String
}

enum PerfumeryHistoryLoader {
    static func loadLegacy(dateKey: String, on database: any Database) async throws -> LegacyPerfumeryHistoryItem? {
        guard let model = try await LegacyPerfumeryHistoryModel.query(on: database)
            .filter(\.$dateKey == dateKey).first() else {
            return nil
        }
        return LegacyPerfumeryHistoryItem(
            year: model.year,
            perfumeName: model.perfumeName,
            shortStory: model.shortStory,
            fullStory: model.fullStory,
            imageUrl: model.imageUrl
        )
    }

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
