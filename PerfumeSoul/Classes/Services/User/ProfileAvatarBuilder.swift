//
//  ProfileAvatarBuilder.swift
//  PerfumeSoul
//
//  Created by afon.com on 04.08.2026.
//

import Foundation

protocol ProfileAvatarBuilder {
    func makeAvatar(name: String) -> ProfileAvatar
}

struct ProfileAvatar: Equatable {
    let initials: String
    let gradientColors: [ProfileAvatarColor]
}

// The case list and its order are part of the generated avatar output.
// makeGradientColors derives stable name -> color-pair mappings from allCases.count
// and each case index, so adding, removing, or reordering cases reshuffles existing
// users' avatars. Treat palette edits as a visible product change and update the
// golden avatar tests deliberately when that reshuffle is intended.
// The zodiac* cases share assets with the horoscope feature; re-check initials contrast when those asset values change.
enum ProfileAvatarColor: CaseIterable, Equatable {
    case zodiacBlue
    case zodiacPurple
    case zodiacBrown
    case zodiacPink
    case zodiacGray
    case avatarOcean
    case avatarTeal
    case avatarAmber
}

final class ProfileAvatarBuilderImpl {}

extension ProfileAvatarBuilderImpl: ProfileAvatarBuilder {
    func makeAvatar(name: String) -> ProfileAvatar {
        let initials = makeInitials(name: name)

        return ProfileAvatar(
            initials: initials,
            gradientColors: makeGradientColors(key: normalizedName(name))
        )
    }
}

extension ProfileAvatarBuilderImpl {
    private func makeInitials(name: String) -> String {
        let result = name
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
            .map { String($0).uppercased().prefix(1) }
            .joined()

        return result.isEmpty ? "?" : result
    }

    private func normalizedName(_ name: String) -> String {
        name
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .lowercased()
            .precomposedStringWithCanonicalMapping
    }

    private func makeGradientColors(key: String) -> [ProfileAvatarColor] {
        let colors = ProfileAvatarColor.allCases
        guard colors.count > 1 else {
            return colors
        }

        let hash = key.unicodeScalars.reduce(UInt32(5381)) { result, scalar in
            result &* 33 &+ UInt32(scalar.value)
        }
        let mixed = hash ^ (hash >> 15)
        let baseIndex = Int(mixed % UInt32(colors.count))
        let accentOffset = Int((mixed / UInt32(colors.count)) % UInt32(colors.count - 1)) + 1
        let accentIndex = (baseIndex + accentOffset) % colors.count

        return [colors[baseIndex], colors[accentIndex]]
    }
}
