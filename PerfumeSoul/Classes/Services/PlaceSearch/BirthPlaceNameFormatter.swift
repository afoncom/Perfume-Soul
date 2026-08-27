//
//  BirthPlaceNameFormatter.swift
//  PerfumeSoul
//

import Foundation

enum BirthPlaceNameFormatter {
    static func format(title: String?, subtitle: String?) -> String {
        let primary = trimmed(title) ?? ""
        let components = (subtitle?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? [])
            .reduce(into: [String]()) { result, component in
                guard !place(component, matchesComponentIn: primary) else {
                    return
                }

                guard !result.contains(where: { place(component, matchesComponentIn: $0) }) else {
                    return
                }

                result.append(component)
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

    static func place(_ name: String, matchesComponentIn value: String) -> Bool {
        let normalizedName = normalizePlaceComponent(name)
        let valueComponents = value
            .split(separator: ",")
            .map(String.init)
            .map(normalizePlaceComponent)

        return valueComponents.contains(normalizedName)
    }

    private static func normalizePlaceComponent(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
