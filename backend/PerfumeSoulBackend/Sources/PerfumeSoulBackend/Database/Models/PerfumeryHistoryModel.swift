import Fluent

final class PerfumeryHistoryModel: Model, @unchecked Sendable {
    static let schema = "perfumery_history_entries"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "date_key")
    var dateKey: String

    @Field(key: "event_year")
    var eventYear: Int

    @Field(key: "title_ru")
    var titleRu: String

    @Field(key: "title_en")
    var titleEn: String

    @Field(key: "full_story_ru")
    var fullStoryRu: String

    @Field(key: "full_story_en")
    var fullStoryEn: String

    init() { }

    init(entry: PerfumeryHistorySeedEntry) {
        dateKey = entry.dateKey
        eventYear = entry.eventYear
        titleRu = entry.titleRu
        titleEn = entry.titleEn
        fullStoryRu = entry.fullStoryRu
        fullStoryEn = entry.fullStoryEn
    }
}
