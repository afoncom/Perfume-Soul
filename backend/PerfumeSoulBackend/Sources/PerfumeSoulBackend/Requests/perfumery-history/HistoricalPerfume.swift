import Fluent

struct PerfumeryHistoryItem: Codable, Equatable {
    let year: Int
    let perfumeName: String
    let shortStory: String
    let fullStory: String
    let imageUrl: String
}

enum PerfumeryHistoryLoader {
    static func load(
        dateKey: String,
        on database: any Database
    ) async throws -> PerfumeryHistoryItem? {
        guard let item = try await PerfumeryHistoryModel.query(on: database)
            .filter(\.$dateKey == dateKey)
            .first()
        else {
            return nil
        }

        return PerfumeryHistoryItem(model: item)
    }
}

private extension PerfumeryHistoryItem {
    init(model: PerfumeryHistoryModel) {
        self.year = model.year
        self.perfumeName = model.perfumeName
        self.shortStory = model.shortStory
        self.fullStory = model.fullStory
        self.imageUrl = model.imageUrl
    }
}
