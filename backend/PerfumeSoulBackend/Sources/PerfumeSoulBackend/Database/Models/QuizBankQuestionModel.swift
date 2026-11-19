import Fluent

final class QuizBankQuestionModel: Model, @unchecked Sendable {
    static let schema = "quiz_bank_questions"

    @ID(custom: .id, generatedBy: .user)
    var id: Int?

    @Field(key: "payload")
    var payload: QuizBankEntry

    init() { }
}
