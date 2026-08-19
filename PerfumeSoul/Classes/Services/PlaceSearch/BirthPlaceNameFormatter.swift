//
//  BirthPlaceNameFormatter.swift
//  PerfumeSoul
//

import Foundation

enum BirthPlaceNameFormatter {
    static func format(title: String?, subtitle: String?) -> String {
        let primary = trimmed(title) ?? ""
        var components = subtitle?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        if let first = components.first, isSamePlaceComponent(primary, first) {
            components.removeFirst()
        }

        guard !primary.isEmpty else {
            return components.joined(separator: ", ")
        }

        guard !components.isEmpty else {
            return primary
        }

        return "\(primary), \(components.joined(separator: ", "))"
    }

    private static func trimmed(_ value: String?) -> String? {
        let result = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return result?.isEmpty == false ? result : nil
    }

    static func isSamePlaceComponent(_ lhs: String, _ rhs: String) -> Bool {
        let normalizedLHS = normalizePlaceComponent(lhs)
        let rhsComponents = rhs
            .split(separator: ",")
            .map(String.init)
            .map(normalizePlaceComponent)

        return rhsComponents.contains(normalizedLHS)
    }

    private static func normalizePlaceComponent(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
