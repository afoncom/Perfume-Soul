//
//  ProfileDescriptionBuilder.swift
//  PerfumeSoul
//
//  Created by Codex on 17.07.2026.
//

import Foundation

protocol ProfileDescriptionBuilder {
    func build(profile: Profile, calculation: ProfileCalculation) -> ProfileDescription
}

final class ProfileDescriptionBuilderImpl {
}

struct ElementBalanceProfile: Equatable {
    let dominantElement: ZodiacElement
    let weakElement: ZodiacElement
    let spread: Int
    let isBalanced: Bool
}

extension ProfileDescriptionBuilderImpl: ProfileDescriptionBuilder {
    func build(profile: Profile, calculation: ProfileCalculation) -> ProfileDescription {
        let natalChart = calculation.natalChart
        let elementProfile = makeElementBalanceProfile(from: calculation.elementBalance)
        let synthesis = makeSynthesis(
            sun: natalChart.sun.sign,
            moon: natalChart.moon.sign,
            ascendant: natalChart.ascendant.sign,
            dominantElement: elementProfile.dominantElement,
            weakElement: elementProfile.weakElement,
            hasBalancedElementSpread: elementProfile.isBalanced
        )

        return ProfileDescription(
            title: localized("profileDescription.title", profile.name),
            subtitle: subtitle(
                sun: natalChart.sun.sign,
                moon: natalChart.moon.sign,
                ascendant: natalChart.ascendant.sign
            ),
            summary: synthesis.summary,
            insights: [
                insight(
                    placement: .sun,
                    sign: natalChart.sun.sign
                ),
                insight(
                    placement: .moon,
                    sign: natalChart.moon.sign
                ),
                insight(
                    placement: .ascendant,
                    sign: natalChart.ascendant.sign
                ),
                elementInsight(
                    element: elementProfile.dominantElement,
                    isDominant: true
                ),
                elementInsight(
                    element: elementProfile.weakElement,
                    isDominant: false
                ),
                ProfileDescriptionInsight(
                    iconSystemName: "sparkles",
                    style: .synthesis,
                    title: synthesis.title,
                    description: synthesis.description
                )
            ]
        )
    }
}

extension ProfileDescriptionBuilderImpl {
    private static let balancedElementSpreadThreshold = 10

    private enum Placement {
        case sun
        case moon
        case ascendant
    }

    private struct Synthesis {
        let title: String
        let description: String
        let summary: String
    }

    private func subtitle(
        sun: ZodiacSign,
        moon: ZodiacSign,
        ascendant: ZodiacSign
    ) -> String {
        localized(
            "profileDescription.subtitle",
            sun.displayName,
            moon.displayName,
            ascendant.displayName
        )
    }

    private func insight(placement: Placement, sign: ZodiacSign) -> ProfileDescriptionInsight {
        switch placement {
        case .sun:
            return ProfileDescriptionInsight(
                iconSystemName: "sun.max.fill",
                style: .sun,
                title: localized("profileDescription.placement.sun.title", sign.displayName),
                description: localized("profileDescription.sun.\(sign.rawValue)")
            )
        case .moon:
            return ProfileDescriptionInsight(
                iconSystemName: "moon.fill",
                style: .moon,
                title: localized("profileDescription.placement.moon.title", sign.displayName),
                description: localized("profileDescription.moon.\(sign.rawValue)")
            )
        case .ascendant:
            return ProfileDescriptionInsight(
                iconSystemName: "circle.grid.3x3.fill",
                style: .ascendant,
                title: localized("profileDescription.placement.ascendant.title", sign.displayName),
                description: localized("profileDescription.ascendant.\(sign.rawValue)")
            )
        }
    }

    private func elementInsight(
        element: ZodiacElement,
        isDominant: Bool
    ) -> ProfileDescriptionInsight {
        ProfileDescriptionInsight(
            iconSystemName: isDominant ? "flame.fill" : "leaf.fill",
            style: isDominant ? .dominantElement : .weakElement,
            title: isDominant
                ? localized("profileDescription.element.dominantTitle", element.displayName)
                : localized("profileDescription.element.weakTitle", element.displayName),
            description: isDominant
                ? localized("profileDescription.element.dominant.\(element.key)")
                : localized("profileDescription.element.weak.\(element.key)")
        )
    }

    func makeElementBalanceProfile(from balance: ElementBalance) -> ElementBalanceProfile {
        let values = elementValues(from: balance)
        let dominantElement = values.max(by: compareElementValues)?.element ?? .fire
        let weakElement = values.min(by: compareElementValues)?.element ?? .earth
        let maxValue = values.map(\.value).max() ?? 0
        let minValue = values.map(\.value).min() ?? 0
        let spread = maxValue - minValue

        return ElementBalanceProfile(
            dominantElement: dominantElement,
            weakElement: weakElement,
            spread: spread,
            isBalanced: spread <= Self.balancedElementSpreadThreshold
        )
    }

    private func elementValues(from balance: ElementBalance) -> [(element: ZodiacElement, value: Int)] {
        [
            (.fire, balance.fire),
            (.earth, balance.earth),
            (.air, balance.air),
            (.water, balance.water)
        ]
    }

    private func compareElementValues(
        lhs: (element: ZodiacElement, value: Int),
        rhs: (element: ZodiacElement, value: Int)
    ) -> Bool {
        if lhs.value == rhs.value {
            return lhs.element.priority > rhs.element.priority
        }

        return lhs.value < rhs.value
    }

    private func makeSynthesis(
        sun: ZodiacSign,
        moon: ZodiacSign,
        ascendant: ZodiacSign,
        dominantElement: ZodiacElement,
        weakElement: ZodiacElement,
        hasBalancedElementSpread: Bool
    ) -> Synthesis {
        if sun == moon && moon == ascendant {
            return Synthesis(
                title: localized("profileDescription.synthesis.veryFocused.title"),
                description: localized("profileDescription.synthesis.veryFocused.description"),
                summary: localized("profileDescription.synthesis.veryFocused.summary", sun.displayName)
            )
        }

        if sun == moon {
            return Synthesis(
                title: localized("profileDescription.synthesis.alignedInner.title"),
                description: localized("profileDescription.synthesis.alignedInner.description"),
                summary: localized("profileDescription.synthesis.alignedInner.summary", sun.displayName)
            )
        }

        if sun.element == moon.element && moon.element == ascendant.element {
            return Synthesis(
                title: localized("profileDescription.synthesis.elementSignature.title", dominantElement.displayName),
                description: localized("profileDescription.synthesis.elementSignature.description"),
                summary: localized("profileDescription.synthesis.elementSignature.summary", dominantElement.displayName.lowercased())
            )
        }

        if sun.element == moon.element {
            return Synthesis(
                title: localized("profileDescription.synthesis.stableInner.title"),
                description: localized("profileDescription.synthesis.stableInner.description"),
                summary: localized("profileDescription.synthesis.stableInner.summary", ascendant.displayName)
            )
        }

        if sun.element == ascendant.element {
            return Synthesis(
                title: localized("profileDescription.synthesis.clearOuter.title"),
                description: localized("profileDescription.synthesis.clearOuter.description"),
                summary: localized("profileDescription.synthesis.clearOuter.summary")
            )
        }

        if moon.element == ascendant.element {
            return Synthesis(
                title: localized("profileDescription.synthesis.visibleEmotional.title"),
                description: localized("profileDescription.synthesis.visibleEmotional.description"),
                summary: localized("profileDescription.synthesis.visibleEmotional.summary")
            )
        }

        if areOppositeElements(sun.element, moon.element) {
            return Synthesis(
                title: localized("profileDescription.synthesis.creativeContrast.title"),
                description: localized("profileDescription.synthesis.creativeContrast.description"),
                summary: localized("profileDescription.synthesis.creativeContrast.summary")
            )
        }

        if hasBalancedElementSpread {
            return Synthesis(
                title: localized("profileDescription.synthesis.balanced.title"),
                description: localized("profileDescription.synthesis.balanced.description"),
                summary: localized("profileDescription.synthesis.balanced.summary")
            )
        }

        return Synthesis(
            title: localized("profileDescription.synthesis.layered.title"),
            description: localized("profileDescription.synthesis.layered.description"),
            summary: localized(
                "profileDescription.synthesis.layered.summary",
                sun.displayName,
                moon.displayName,
                ascendant.displayName
            )
        )
    }

    private func localized(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }

    private func localized(_ key: String, _ args: CVarArg...) -> String {
        String(format: localized(key), locale: Locale.current, arguments: args)
    }

    private func areOppositeElements(_ lhs: ZodiacElement, _ rhs: ZodiacElement) -> Bool {
        switch (lhs, rhs) {
        case (.fire, .water), (.water, .fire), (.earth, .air), (.air, .earth):
            true
        default:
            false
        }
    }
}

extension ZodiacSign {
    fileprivate var displayName: String {
        Bundle.main.localizedString(forKey: "horoscope.sign.\(rawValue)", value: nil, table: nil)
    }
}

extension ZodiacElement {
    fileprivate var displayName: String {
        Bundle.main.localizedString(forKey: "profile.element.\(key)", value: nil, table: nil)
    }

    fileprivate var key: String {
        switch self {
        case .fire: "fire"
        case .earth: "earth"
        case .air: "air"
        case .water: "water"
        }
    }

    fileprivate var priority: Int {
        switch self {
        case .fire: 0
        case .earth: 1
        case .air: 2
        case .water: 3
        }
    }
}
