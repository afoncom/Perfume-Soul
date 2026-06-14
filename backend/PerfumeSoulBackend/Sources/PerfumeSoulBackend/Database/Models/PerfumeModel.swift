import Fluent

final class PerfumeModel: Model, @unchecked Sendable {
    static let schema = "perfumes"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "perfume_name")
    var perfumeName: String

    @Parent(key: "brand_id")
    var brand: BrandModel

    @Children(for: \.$perfume)
    var notes: [PerfumeNoteModel]

    init() { }

    init(id: Int? = nil, perfumeName: String, brandID: Int) {
        self.id = id
        self.perfumeName = perfumeName
        self.$brand.id = brandID
    }
}
