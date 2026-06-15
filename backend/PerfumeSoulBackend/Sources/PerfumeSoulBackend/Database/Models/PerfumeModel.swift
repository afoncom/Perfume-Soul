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

    @Parent(key: "brand_id")
    var brand: BrandModel

    @Children(for: \.$perfume)
    var notes: [PerfumeNoteModel]

    init() { }

    init(
        id: Int? = nil,
        perfumeName: String,
        longevityScore: Int? = nil,
        sillageScore: Int? = nil,
        brandID: Int
    ) {
        self.id = id
        self.perfumeName = perfumeName
        self.longevityScore = longevityScore
        self.sillageScore = sillageScore
        self.$brand.id = brandID
    }
}
