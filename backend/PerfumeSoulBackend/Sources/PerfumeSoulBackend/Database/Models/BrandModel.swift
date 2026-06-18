import Fluent

final class BrandModel: Model, @unchecked Sendable {
    static let schema = "brands"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "brand")
    var name: String

    @Children(for: \.$brand)
    var perfumes: [PerfumeModel]

    init() { }

    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
