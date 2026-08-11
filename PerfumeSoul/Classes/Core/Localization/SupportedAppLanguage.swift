import Foundation

enum SupportedAppLanguage {
    static var currentCode: String {
        code(for: Bundle.main.preferredLocalizations.first)
    }

    static func code(for preferredLocalization: String?) -> String {
        preferredLocalization == "ru" ? "ru" : "en"
    }
}
