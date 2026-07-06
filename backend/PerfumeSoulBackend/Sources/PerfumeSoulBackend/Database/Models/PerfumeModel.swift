import Fluent

final class PerfumeModel: Model, @unchecked Sendable {
    static let schema = "perfumes"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "perfume_name")
    var perfumeName: String

    @OptionalField(key: "longevity_score")
    var longevityScore: Int?

    @OptionalField(key: "sillage_score")
    var sillageScore: Int?

    @OptionalField(key: "concentration")
    var concentration: String?

    @OptionalField(key: "fragrance_family")
    var fragranceFamily: String?

    @OptionalField(key: "season_profile")
    var seasonProfile: String?

    @OptionalField(key: "occasion_profile")
    var occasionProfile: String?

    @OptionalField(key: "style_profile")
    var styleProfile: String?

    @OptionalField(key: "gender_profile")
    var genderProfile: String?

    @OptionalField(key: "mood_profile")
    var moodProfile: String?

    @Parent(key: "brand_id")
    var brand: BrandModel

    @Children(for: \.$perfume)
    var notes: [PerfumeNoteModel]

    @Children(for: \.$perfume)
    var accords: [PerfumeAccordModel]

    init() { }

    init(
        id: Int? = nil,
        perfumeName: String,
        longevityScore: Int? = nil,
        sillageScore: Int? = nil,
        concentration: String? = nil,
        fragranceFamily: String? = nil,
        seasonProfile: String? = nil,
        occasionProfile: String? = nil,
        styleProfile: String? = nil,
        genderProfile: String? = nil,
        moodProfile: String? = nil,
        brandID: Int
    ) {
        self.id = id
        self.perfumeName = perfumeName
        self.longevityScore = longevityScore
        self.sillageScore = sillageScore
        self.concentration = concentration
        self.fragranceFamily = fragranceFamily
        self.seasonProfile = seasonProfile
        self.occasionProfile = occasionProfile
        self.styleProfile = styleProfile
        self.genderProfile = genderProfile
        self.moodProfile = moodProfile
        self.$brand.id = brandID
    }
}
