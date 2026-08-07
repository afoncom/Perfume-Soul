//
//  BirthPlaceNameFormatter.swift
//  PerfumeSoul
//

import Foundation

enum BirthPlaceNameFormatter {
    static func format(title: String?, subtitle: String?, fallback: String? = nil) -> String {
        let primary = trimmed(title) ?? trimmed(fallback) ?? ""
        let components = subtitle?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        guard let region = components.count > 1 ? components.dropLast().joined(separator: ", ") : components.first,
            !isSamePlaceComponent(primary, region) else {
            return primary
        }

        return "\(primary), \(region)"
    }

    private static func trimmed(_ value: String?) -> String? {
        let result = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return result?.isEmpty == false ? result : nil
    }

    private static func isSamePlaceComponent(_ lhs: String, _ rhs: String) -> Bool {
        lhs.compare(
            rhs,
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: .current
        ) == .orderedSame
    }
}
