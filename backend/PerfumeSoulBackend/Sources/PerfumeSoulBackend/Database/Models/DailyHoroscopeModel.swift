import Fluent

final class DailyHoroscopeModel: Model, @unchecked Sendable {
    static let schema = "daily_horoscopes"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "sign")
    var sign: String

    @Field(key: "energy_of_day")
    var energyOfDay: String

    @Field(key: "sort_order")
    var sortOrder: Int

    init() { }

    init(
        id: Int? = nil,
        sign: String,
        energyOfDay: String,
        sortOrder: Int
    ) {
        self.id = id
        self.sign = sign
        self.energyOfDay = energyOfDay
        self.sortOrder = sortOrder
    }
}
