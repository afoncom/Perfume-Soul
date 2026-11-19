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

// Preserve the table used by released clients while the versioned catalog uses entries.
final class LegacyPerfumeryHistoryModel: Model, @unchecked Sendable {
    static let schema = "perfumery_history"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "date_key")
    var dateKey: String

    @Field(key: "year")
    var year: Int

    @Field(key: "perfume_name")
    var perfumeName: String

    @Field(key: "short_story")
    var shortStory: String

    @Field(key: "full_story")
    var fullStory: String

    @Field(key: "image_url")
    var imageUrl: String

    init() { }

    init(
        id: Int? = nil,
        dateKey: String,
        year: Int,
        perfumeName: String,
        shortStory: String,
        fullStory: String,
        imageUrl: String
    ) {
        self.id = id
        self.dateKey = dateKey
        self.year = year
        self.perfumeName = perfumeName
        self.shortStory = shortStory
        self.fullStory = fullStory
        self.imageUrl = imageUrl
    }
}
