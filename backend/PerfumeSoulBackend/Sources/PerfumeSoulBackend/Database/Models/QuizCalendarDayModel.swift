import Fluent

final class QuizCalendarDayModel: Model, @unchecked Sendable {
    static let schema = "quiz_calendar_days"

    @ID(custom: "day_key", generatedBy: .user)
    var id: String?

    @Field(key: "question_ids")
    var questionIDs: [Int]

    init() { }
}
