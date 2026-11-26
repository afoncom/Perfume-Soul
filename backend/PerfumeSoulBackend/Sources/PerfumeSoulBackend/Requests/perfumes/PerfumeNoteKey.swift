import Foundation

/// API identity aliases, not display translations. Display text belongs to the iOS catalog.
enum PerfumeNoteKey {
    private static let aliasesByKey: [String: [String]] = [
        "aldehydes": ["Альдегиды", "Aldehydes", "aldehydes"],
        "amber": ["Амбра", "Amber", "amber"],
        "ambergris": ["Серая амбра", "Ambergris", "ambergris"],
        "ambroxan": ["Амброксан", "Ambroxan", "ambroxan"],
        "apple": ["Яблоко", "Apple", "apple"],
        "apricot": ["Абрикос", "Apricot", "apricot"],
        "basil": ["Базилик", "Basil", "basil"],
        "benzoin": ["Бензоин", "Benzoin", "benzoin"],
        "bergamot": ["Бергамот", "Bergamot", "bergamot"],
        "birch": ["Берёза", "Birch", "birch"],
        "black_currant": ["Чёрная смородина", "Black Currant", "black_currant"],
        "black_pepper": ["Чёрный перец", "Black Pepper", "black_pepper"],
        "brazilian_rosewood": ["Бразильский палисандр", "Brazilian Rosewood", "brazilian_rosewood"],
        "cardamom": ["Кардамон", "Cardamom", "cardamom"],
        "carnation": ["Гвоздика", "Carnation", "carnation"],
        "caramel": ["Карамель", "Caramel", "caramel"],
        "cashmeran": ["Кашмеран", "Cashmeran", "cashmeran"],
        "cashmere_wood": ["Кашемировое дерево", "Cashmere Wood", "cashmere_wood"],
        "cedar": ["Кедр", "Cedar", "cedar"],
        "cherry": ["Вишня", "Cherry", "cherry"],
        "cinnamon": ["Корица", "Cinnamon", "cinnamon"],
        "citruses": ["Цитрусы", "Citruses", "citruses"],
        "clary_sage": ["Мускатный шалфей", "Clary Sage", "clary_sage"],
        "cloves": ["Пряная гвоздика", "Cloves", "cloves"],
        "coconut": ["Кокос", "Coconut", "coconut"],
        "coffee": ["Кофе", "Coffee", "coffee"],
        "coriander": ["Кориандр", "Coriander", "coriander"],
        "cyclamen": ["Цикламен", "Cyclamen", "cyclamen"],
        "cypress": ["Кипарис", "Cypress", "cypress"],
        "damask_rose": ["Дамасская роза", "Damask Rose", "damask_rose"],
        "elemi": ["Элеми", "Elemi", "elemi"],
        "fig": ["Инжир", "Fig", "fig"],
        "fig_leaf": ["Лист инжира", "Fig Leaf", "fig_leaf"],
        "fir": ["Пихта", "Fir", "fir"],
        "floral_notes": ["Цветочные ноты", "Floral Notes", "floral_notes"],
        "freesia": ["Фрезия", "Freesia", "freesia"],
        "fruity_notes": ["Фруктовые ноты", "Fruity Notes", "fruity_notes"],
        "galbanum": ["Гальбанум", "Galbanum", "galbanum"],
        "gardenia": ["Гардения", "Gardenia", "gardenia"],
        "geranium": ["Герань", "Geranium", "geranium"],
        "ginger": ["Имбирь", "Ginger", "ginger"],
        "grapefruit": ["Грейпфрут", "Grapefruit", "grapefruit"],
        "green_notes": ["Зелёные ноты", "Green Notes", "green_notes"],
        "green_tea": ["Зелёный чай", "Green Tea", "green_tea"],
        "guaiac_wood": ["Гваяковое дерево", "Guaiac Wood", "guaiac_wood"],
        "hawthorn": ["Боярышник", "Hawthorn", "hawthorn"],
        "heliotrope": ["Гелиотроп", "Heliotrope", "heliotrope"],
        "honey": ["Мёд", "Honey", "honey"],
        "honeysuckle": ["Жимолость", "Honeysuckle", "honeysuckle"],
        "hyacinth": ["Гиацинт", "Hyacinth", "hyacinth"],
        "incense": ["Ладан", "Incense", "incense"],
        "iris": ["Ирис", "Iris", "iris"],
        "iso_e_super": ["Исо Е Супер", "Iso E Super", "iso_e_super"],
        "jasmine": ["Жасмин", "Jasmine", "jasmine"],
        "jasmine_sambac": ["Жасмин самбак", "Jasmine Sambac", "jasmine_sambac"],
        "juniper": ["Можжевельник", "Juniper", "juniper"],
        "juniper_berries": ["Ягоды можжевельника", "Juniper Berries", "juniper_berries"],
        "labdanum": ["Лабданум", "Labdanum", "labdanum"],
        "lavender": ["Лаванда", "Lavender", "lavender"],
        "leather": ["Кожа", "Leather", "leather"],
        "lemon": ["Лимон", "Lemon", "lemon"],
        "lemon_verbena": ["Лимонная вербена", "Lemon Verbena", "lemon_verbena"],
        "lilac": ["Сирень", "Lilac", "lilac"],
        "lily": ["Лилия", "Lily", "lily"],
        "lily_of_the_valley": ["Ландыш", "Lily-of-the-Valley", "lily_of_the_valley"],
        "lime": ["Лайм", "Lime", "lime"],
        "lotus": ["Лотос", "Lotus", "lotus"],
        "lychee": ["Личи", "Lychee", "lychee"],
        "magnolia": ["Магнолия", "Magnolia", "magnolia"],
        "mandarin_orange": ["Мандарин", "Mandarin Orange", "mandarin_orange"],
        "mate": ["Мате", "Mate", "mate"],
        "melon": ["Дыня", "Melon", "melon"],
        "mimosa": ["Мимоза", "Mimosa", "mimosa"],
        "mint": ["Мята", "Mint", "mint"],
        "moss": ["Мох", "Moss", "moss"],
        "musk": ["Мускус", "Musk", "musk"],
        "myrrh": ["Мирра", "Myrrh", "myrrh"],
        "narcissus": ["Нарцисс", "Narcissus", "narcissus"],
        "neroli": ["Нероли", "Neroli", "neroli"],
        "nutmeg": ["Мускатный орех", "Nutmeg", "nutmeg"],
        "oakmoss": ["Дубовый мох", "Oakmoss", "oakmoss"],
        "orange": ["Апельсин", "Orange", "orange"],
        "orange_blossom": ["Апельсиновый цвет", "Orange Blossom", "orange_blossom"],
        "orris_root": ["Корень ириса", "Orris Root", "orris_root"],
        "osmanthus": ["Османтус", "Osmanthus", "osmanthus"],
        "oud": ["Уд", "Oud", "oud", "Агаровое дерево (уд)", "Агаровое дерево", "Agarwood"],
        "patchouli": ["Пачули", "Patchouli", "patchouli"],
        "peach": ["Персик", "Peach", "peach"],
        "pear": ["Груша", "Pear", "pear"],
        "peony": ["Пион", "Peony", "peony"],
        "pepper": ["Перец", "Pepper", "pepper"],
        "petitgrain": ["Петитгрейн", "Petitgrain", "petitgrain"],
        "pineapple": ["Ананас", "Pineapple", "pineapple"],
        "pink_pepper": ["Розовый перец", "Pink Pepper", "pink_pepper"],
        "plum": ["Слива", "Plum", "plum"],
        "powdery_notes": ["Пудровые ноты", "Powdery Notes", "powdery_notes"],
        "raspberry": ["Малина", "Raspberry", "raspberry"],
        "rose": ["Роза", "Rose", "rose"],
        "rosemary": ["Розмарин", "Rosemary", "rosemary"],
        "rosewood": ["Палисандр", "Rosewood", "rosewood"],
        "rum": ["Ром", "Rum", "rum"],
        "saffron": ["Шафран", "Saffron", "saffron"],
        "sage": ["Шалфей", "Sage", "sage"],
        "sandalwood": ["Сандал", "Sandalwood", "sandalwood", "Сандаловое дерево"],
        "marine_notes": ["Морские ноты", "Sea Notes", "marine_notes"],
        "sichuan_pepper": ["Сычуанский перец", "Sichuan Pepper", "sichuan_pepper"],
        "smoke": ["Дым", "Smoke", "smoke"],
        "styrax": ["Стиракс", "Styrax", "styrax"],
        "suede": ["Замша", "Suede", "suede"],
        "tea": ["Чай", "Tea", "tea"],
        "tobacco": ["Табак", "Tobacco", "tobacco"],
        "tonka_bean": ["Бобы тонка", "Tonka Bean", "tonka_bean"],
        "tuberose": ["Тубероза", "Tuberose", "tuberose"],
        "vanilla": ["Ваниль", "Vanilla", "vanilla"],
        "vetiver": ["Ветивер", "Vetiver", "vetiver"],
        "violet": ["Фиалка", "Violet", "violet"],
        "violet_leaf": ["Лист фиалки", "Violet Leaf", "violet_leaf"],
        "water_jasmine": ["Водяной жасмин", "Water Jasmine", "water_jasmine"],
        "water_lily": ["Кувшинка", "Water Lily", "water_lily"],
        "water_notes": ["Водные ноты", "Water Notes", "water_notes"],
        "white_flowers": ["Белые цветы", "White Flowers", "white_flowers"],
        "white_musk": ["Белый мускус", "White Musk", "white_musk"],
        "woody_notes": ["Древесные ноты", "Woody Notes", "woody_notes"],
        "ylang_ylang": ["Иланг-иланг", "Ylang-Ylang", "ylang_ylang"],
        "yuzu": ["Юдзу", "Yuzu", "yuzu"]
    ]

    private static let keysByAlias: [String: String] = {
        var result: [String: String] = [:]
        for (key, aliases) in aliasesByKey {
            for alias in aliases { result[normalized(alias)] = key }
        }
        return result
    }()

    static func key(for name: String, id: Int? = nil) -> String {
        if let key = keysByAlias[normalized(name)] {
            return key
        }
        if let id {
            return "note:\(id)"
        }
        return "unmapped:\(normalized(name))"
    }

    static func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }
}
