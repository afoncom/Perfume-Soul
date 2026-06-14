import Fluent

enum PerfumeNoteType: String, Codable {
    case top
    case middle
    case base
}

final class PerfumeNoteModel: Model, @unchecked Sendable {
    static let schema = "perfume_notes"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Parent(key: "perfume_id")
    var perfume: PerfumeModel

    @Parent(key: "note_id")
    var note: NoteModel

    @Enum(key: "note_type")
    var noteType: PerfumeNoteType

    @Field(key: "sort_order")
    var sortOrder: Int

    init() { }

    init(
        id: Int? = nil,
        perfumeID: Int,
        noteID: Int,
        noteType: PerfumeNoteType,
        sortOrder: Int
    ) {
        self.id = id
        self.$perfume.id = perfumeID
        self.$note.id = noteID
        self.noteType = noteType
        self.sortOrder = sortOrder
    }
}
