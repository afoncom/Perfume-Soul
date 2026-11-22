import Fluent

final class DailyHoroscopeEntryModel: Model, @unchecked Sendable {
    static let schema = "daily_horoscope_entries"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "date_key")
    var dateKey: String

    @Field(key: "sign")
    var sign: String

    @Field(key: "energy_of_day_ru")
    var energyOfDayRu: String

    @Field(key: "energy_of_day_en")
    var energyOfDayEn: String

    @Field(key: "sort_order")
    var sortOrder: Int

    init() { }

    init(
        dateKey: String,
        sign: String,
        energyOfDayRu: String,
        energyOfDayEn: String,
        sortOrder: Int
    ) {
        self.dateKey = dateKey
        self.sign = sign
        self.energyOfDayRu = energyOfDayRu
        self.energyOfDayEn = energyOfDayEn
        self.sortOrder = sortOrder
    }
}
