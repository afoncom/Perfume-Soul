import Fluent

final class PerfumeryHistoryModel: Model, @unchecked Sendable {
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
