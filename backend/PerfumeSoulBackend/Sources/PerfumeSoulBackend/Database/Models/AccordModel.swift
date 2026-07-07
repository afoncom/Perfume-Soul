import Fluent

final class AccordModel: Model, @unchecked Sendable {
    static let schema = "accords"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Children(for: \.$accord)
    var perfumes: [PerfumeAccordModel]

    init() { }

    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
