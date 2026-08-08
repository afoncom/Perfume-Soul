import Fluent
import FluentSQL

struct AddNoteEnglishNameMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("ALTER TABLE notes ADD COLUMN IF NOT EXISTS name_en TEXT")
            .run()

        try await sqlDatabase
            .raw("""
            UPDATE notes
            SET name_en = CASE name
                WHEN 'Амбра' THEN 'amber'
                WHEN 'Амброксан' THEN 'ambroxan'
                WHEN 'Апельсиновый цвет' THEN 'orange blossom'
                WHEN 'Бергамот' THEN 'bergamot'
                WHEN 'Бобы тонка' THEN 'tonka bean'
                WHEN 'Ваниль' THEN 'vanilla'
                WHEN 'Ветивер' THEN 'vetiver'
                WHEN 'Герань' THEN 'geranium'
                WHEN 'Грейпфрут' THEN 'grapefruit'
                WHEN 'Груша' THEN 'pear'
                WHEN 'Жасмин' THEN 'jasmine'
                WHEN 'Имбирь' THEN 'ginger'
                WHEN 'Инжир' THEN 'fig'
                WHEN 'Ирис' THEN 'iris'
                WHEN 'Кардамон' THEN 'cardamom'
                WHEN 'Кедр' THEN 'cedar'
                WHEN 'Кожа' THEN 'leather'
                WHEN 'Кокос' THEN 'coconut'
                WHEN 'Кофе' THEN 'coffee'
                WHEN 'Лабданум' THEN 'labdanum'
                WHEN 'Лаванда' THEN 'lavender'
                WHEN 'Ладан' THEN 'incense'
                WHEN 'Лимон' THEN 'lemon'
                WHEN 'Можжевельник' THEN 'juniper'
                WHEN 'Морские ноты' THEN 'sea notes'
                WHEN 'Мускатный орех' THEN 'nutmeg'
                WHEN 'Мускус' THEN 'musk'
                WHEN 'Мята' THEN 'mint'
                WHEN 'Нероли' THEN 'neroli'
                WHEN 'Палисандр' THEN 'rosewood'
                WHEN 'Пачули' THEN 'patchouli'
                WHEN 'Перец' THEN 'pepper'
                WHEN 'Роза' THEN 'rose'
                WHEN 'Розовый перец' THEN 'pink pepper'
                WHEN 'Ром' THEN 'rum'
                WHEN 'Сандал' THEN 'sandalwood'
                WHEN 'Сычуанский перец' THEN 'Sichuan pepper'
                WHEN 'Табак' THEN 'tobacco'
                WHEN 'Уд' THEN 'oud'
                WHEN 'Чай' THEN 'tea'
                WHEN 'Шафран' THEN 'saffron'
                WHEN 'Яблоко' THEN 'apple'
            END
            WHERE name_en IS NULL
            """)
            .run()

        let missingNames = try await sqlDatabase
            .raw("SELECT name FROM notes WHERE name_en IS NULL ORDER BY name")
            .all()
            .map { try $0.decode(column: "name", as: String.self) }

        guard missingNames.isEmpty else {
            throw DatabaseMigrationError.missingEnglishNoteNames(missingNames)
        }
    }

    func revert(on database: any Database) async throws {
        guard let sqlDatabase = database as? any SQLDatabase else {
            throw DatabaseMigrationError.sqlDatabaseIsRequired
        }

        try await sqlDatabase
            .raw("ALTER TABLE notes DROP COLUMN IF EXISTS name_en")
            .run()
    }
}
