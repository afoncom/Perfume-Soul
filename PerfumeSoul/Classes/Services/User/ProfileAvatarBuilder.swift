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

    static let placeholder = ProfileAvatar(initials: "?")
}

final class ProfileAvatarBuilderImpl {}

extension ProfileAvatarBuilderImpl: ProfileAvatarBuilder {
    func makeAvatar(name: String) -> ProfileAvatar {
        ProfileAvatar(initials: makeInitials(name: name))
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

}
