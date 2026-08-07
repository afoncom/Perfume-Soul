//
//  ProfileAvatarBuilder.swift
//  PerfumeSoul
//
//  Created by Codex on 04.08.2026.
//

import Foundation

protocol ProfileAvatarBuilder {
    func makeAvatar(name: String) -> ProfileAvatar
}

struct ProfileAvatar: Equatable {
    let initials: String
    let gradientColors: [ProfileAvatarColor]
}

enum ProfileAvatarColor: CaseIterable, Equatable {
    case zodiacBlue
    case zodiacPurple
    case zodiacBrown
    case zodiacPink
    case zodiacGray
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
        let initials = name
            .split(whereSeparator: \.isWhitespace)
            .prefix(2)
            .compactMap(\.first)
        let result = String(initials).uppercased()

        return result.isEmpty ? "?" : result
    }

    private func normalizedName(_ name: String) -> String {
        name
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .lowercased()
    }

    private func makeGradientColors(key: String) -> [ProfileAvatarColor] {
        let colors = ProfileAvatarColor.allCases
        guard colors.count > 1 else {
            return colors
        }

        let hash = key.unicodeScalars.reduce(UInt32(5381)) { result, scalar in
            result &* 33 &+ UInt32(scalar.value)
        }
        let baseIndex = Int(hash % UInt32(colors.count))
        let accentOffset = Int((hash / UInt32(colors.count)) % UInt32(colors.count - 1)) + 1
        let accentIndex = (baseIndex + accentOffset) % colors.count

        return [colors[baseIndex], colors[accentIndex]]
    }
}
