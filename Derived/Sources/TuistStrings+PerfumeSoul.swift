// swiftlint:disable all
// Generated using SwiftGen - https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum Discover {
    public enum Compare {
      /// Compare
      public static var button: String { return L10n.tr("Localizable", "discover.compare.button", fallback: "Compare") }
      /// Perfume A
      public static var placeholderA: String { return L10n.tr("Localizable", "discover.compare.placeholderA", fallback: "Perfume A") }
      /// Perfume B
      public static var placeholderB: String { return L10n.tr("Localizable", "discover.compare.placeholderB", fallback: "Perfume B") }
      /// Compare Perfumes
      public static var title: String { return L10n.tr("Localizable", "discover.compare.title", fallback: "Compare Perfumes") }
    }
    public enum FindSimilar {
      /// Find
      public static var button: String { return L10n.tr("Localizable", "discover.findSimilar.button", fallback: "Find") }
      /// Enter perfumes you own to find similar scents.
      public static var subtitle: String { return L10n.tr("Localizable", "discover.findSimilar.subtitle", fallback: "Enter perfumes you own to find similar scents.") }
      /// Find Similar Perfumes
      public static var title: String { return L10n.tr("Localizable", "discover.findSimilar.title", fallback: "Find Similar Perfumes") }
    }
    public enum ScentArchetype {
      /// Start quiz
      public static var button: String { return L10n.tr("Localizable", "discover.scentArchetype.button", fallback: "Start quiz") }
      /// Find Your Scent Archetype
      public static var title: String { return L10n.tr("Localizable", "discover.scentArchetype.title", fallback: "Find Your Scent Archetype") }
    }
  }
  public enum Profile {
    /// Born May 12, 1993  Paris, France
    public static var birthInfo: String { return L10n.tr("Localizable", "profile.birthInfo", fallback: "Born May 12, 1993  Paris, France") }
    public enum Element {
      /// Air
      public static var air: String { return L10n.tr("Localizable", "profile.element.air", fallback: "Air") }
      /// Earth
      public static var earth: String { return L10n.tr("Localizable", "profile.element.earth", fallback: "Earth") }
      /// Fire
      public static var fire: String { return L10n.tr("Localizable", "profile.element.fire", fallback: "Fire") }
      /// Water
      public static var water: String { return L10n.tr("Localizable", "profile.element.water", fallback: "Water") }
    }
    public enum ElementBalance {
      /// Element Balance
      public static var title: String { return L10n.tr("Localizable", "profile.elementBalance.title", fallback: "Element Balance") }
    }
    public enum NatalChart {
      /// Ascendant
      public static var ascendant: String { return L10n.tr("Localizable", "profile.natalChart.ascendant", fallback: "Ascendant") }
      /// Capricorn ♑
      public static var ascendantValue: String { return L10n.tr("Localizable", "profile.natalChart.ascendantValue", fallback: "Capricorn ♑") }
      /// Moon
      public static var moon: String { return L10n.tr("Localizable", "profile.natalChart.moon", fallback: "Moon") }
      /// Libra ♎
      public static var moonValue: String { return L10n.tr("Localizable", "profile.natalChart.moonValue", fallback: "Libra ♎") }
      /// Sun
      public static var sun: String { return L10n.tr("Localizable", "profile.natalChart.sun", fallback: "Sun") }
      /// Taurus ♉
      public static var sunValue: String { return L10n.tr("Localizable", "profile.natalChart.sunValue", fallback: "Taurus ♉") }
      /// My Natal Chart
      public static var title: String { return L10n.tr("Localizable", "profile.natalChart.title", fallback: "My Natal Chart") }
    }
    public enum Profiles {
      /// Profiles
      public static var title: String { return L10n.tr("Localizable", "profile.profiles.title", fallback: "Profiles") }
    }
  }
  public enum Screen {
    /// Added Profiles
    public static var addedProfiles: String { return L10n.tr("Localizable", "screen.addedProfiles", fallback: "Added Profiles") }
    /// Compare Perfumes
    public static var comparePerfumes: String { return L10n.tr("Localizable", "screen.comparePerfumes", fallback: "Compare Perfumes") }
    /// Day in Perfumery
    public static var dayInPerfumery: String { return L10n.tr("Localizable", "screen.dayInPerfumery", fallback: "Day in Perfumery") }
    /// Discover
    public static var discover: String { return L10n.tr("Localizable", "screen.discover", fallback: "Discover") }
    /// Find Perfumes
    public static var findPerfumes: String { return L10n.tr("Localizable", "screen.findPerfumes", fallback: "Find Perfumes") }
    /// Profile
    public static var profile: String { return L10n.tr("Localizable", "screen.profile", fallback: "Profile") }
    /// Settings
    public static var settings: String { return L10n.tr("Localizable", "screen.settings", fallback: "Settings") }
    /// Start Quiz
    public static var startQuiz: String { return L10n.tr("Localizable", "screen.startQuiz", fallback: "Start Quiz") }
    /// Today
    public static var today: String { return L10n.tr("Localizable", "screen.today", fallback: "Today") }
    /// Today's Energy
    public static var todayEnergy: String { return L10n.tr("Localizable", "screen.todayEnergy", fallback: "Today's Energy") }
  }
  public enum Today {
    public enum Aroma {
      /// My vibe
      public static var primaryAction: String { return L10n.tr("Localizable", "today.aroma.primaryAction", fallback: "My vibe") }
      /// Not today
      public static var secondaryAction: String { return L10n.tr("Localizable", "today.aroma.secondaryAction", fallback: "Not today") }
      /// Warm · Deep · Magnetic
      public static var tags: String { return L10n.tr("Localizable", "today.aroma.tags", fallback: "Warm · Deep · Magnetic") }
      /// Aroma of the Day
      public static var title: String { return L10n.tr("Localizable", "today.aroma.title", fallback: "Aroma of the Day") }
    }
    public enum Energy {
      /// Your emotions are deeper and more intense today.
      public static var description: String { return L10n.tr("Localizable", "today.energy.description", fallback: "Your emotions are deeper and more intense today.") }
      /// Moon in Scorpio
      public static var moonTitle: String { return L10n.tr("Localizable", "today.energy.moonTitle", fallback: "Moon in Scorpio") }
      /// Today's Energy
      public static var title: String { return L10n.tr("Localizable", "today.energy.title", fallback: "Today's Energy") }
    }
    public enum History {
      /// One of the most iconic lily-of-the-valley perfumes from Dior.
      public static var description: String { return L10n.tr("Localizable", "today.history.description", fallback: "One of the most iconic lily-of-the-valley perfumes from Dior.") }
      /// Dior released Diorissimo
      public static var eventTitle: String { return L10n.tr("Localizable", "today.history.eventTitle", fallback: "Dior released Diorissimo") }
      /// On This Day in Perfumery
      public static var title: String { return L10n.tr("Localizable", "today.history.title", fallback: "On This Day in Perfumery") }
    }
    public enum Recommended {
      /// Recommended for You
      public static var title: String { return L10n.tr("Localizable", "today.recommended.title", fallback: "Recommended for You") }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

// swiftlint:enable all
