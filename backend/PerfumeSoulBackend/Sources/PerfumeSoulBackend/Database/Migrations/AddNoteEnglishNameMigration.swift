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
                WHEN 'Амбра' THEN 'Amber'
                WHEN 'Амброксан' THEN 'Ambroxan'
                WHEN 'Апельсиновый цвет' THEN 'Orange Blossom'
                WHEN 'Бергамот' THEN 'Bergamot'
                WHEN 'Бобы тонка' THEN 'Tonka Bean'
                WHEN 'Ваниль' THEN 'Vanilla'
                WHEN 'Ветивер' THEN 'Vetiver'
                WHEN 'Герань' THEN 'Geranium'
                WHEN 'Грейпфрут' THEN 'Grapefruit'
                WHEN 'Груша' THEN 'Pear'
                WHEN 'Жасмин' THEN 'Jasmine'
                WHEN 'Имбирь' THEN 'Ginger'
                WHEN 'Инжир' THEN 'Fig'
                WHEN 'Ирис' THEN 'Iris'
                WHEN 'Кардамон' THEN 'Cardamom'
                WHEN 'Кедр' THEN 'Cedar'
                WHEN 'Кожа' THEN 'Leather'
                WHEN 'Кокос' THEN 'Coconut'
                WHEN 'Кофе' THEN 'Coffee'
                WHEN 'Лабданум' THEN 'Labdanum'
                WHEN 'Лаванда' THEN 'Lavender'
                WHEN 'Ладан' THEN 'Incense'
                WHEN 'Лимон' THEN 'Lemon'
                WHEN 'Можжевельник' THEN 'Juniper'
                WHEN 'Морские ноты' THEN 'Sea Notes'
                WHEN 'Мускатный орех' THEN 'Nutmeg'
                WHEN 'Мускус' THEN 'Musk'
                WHEN 'Мята' THEN 'Mint'
                WHEN 'Нероли' THEN 'Neroli'
                WHEN 'Палисандр' THEN 'Rosewood'
                WHEN 'Пачули' THEN 'Patchouli'
                WHEN 'Перец' THEN 'Pepper'
                WHEN 'Роза' THEN 'Rose'
                WHEN 'Розовый перец' THEN 'Pink Pepper'
                WHEN 'Ром' THEN 'Rum'
                WHEN 'Сандал' THEN 'Sandalwood'
                WHEN 'Сычуанский перец' THEN 'Sichuan Pepper'
                WHEN 'Табак' THEN 'Tobacco'
                WHEN 'Уд' THEN 'Oud'
                WHEN 'Чай' THEN 'Tea'
                WHEN 'Шафран' THEN 'Saffron'
                WHEN 'Яблоко' THEN 'Apple'
            END
            WHERE NULLIF(BTRIM(name_en), '') IS NULL
            """)
            .run()

        let missingNames = try await sqlDatabase
            .raw("SELECT name FROM notes WHERE NULLIF(BTRIM(name_en), '') IS NULL ORDER BY name")
            .all()
            .map { try $0.decode(column: "name", as: String.self) }

        if !missingNames.isEmpty {
            database.logger.warning("[notes] missing name_en: \(missingNames)")
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
