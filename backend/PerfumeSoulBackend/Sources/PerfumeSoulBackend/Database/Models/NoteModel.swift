import Fluent

final class NoteModel: Model, @unchecked Sendable {
    static let schema = "notes"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Children(for: \.$note)
    var perfumes: [PerfumeNoteModel]

    init() { }

    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
