import Fluent

final class PerfumeAccordModel: Model, @unchecked Sendable {
    static let schema = "perfume_accords"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Parent(key: "perfume_id")
    var perfume: PerfumeModel

    @Parent(key: "accord_id")
    var accord: AccordModel

    @Field(key: "weight")
    var weight: Double

    init() { }

    init(
        id: Int? = nil,
        perfumeID: Int,
        accordID: Int,
        weight: Double
    ) {
        self.id = id
        self.$perfume.id = perfumeID
        self.$accord.id = accordID
        self.weight = weight
    }
}
