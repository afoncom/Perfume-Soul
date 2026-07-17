//
//  ProfileDescription.swift
//  PerfumeSoul
//
//  Created by Codex on 17.07.2026.
//

import Foundation

struct ProfileDescription: Equatable {
    let title: String
    let subtitle: String
    let summary: String
    let insights: [ProfileDescriptionInsight]
}

struct ProfileDescriptionInsight: Equatable {
    let iconSystemName: String
    let style: ProfileDescriptionInsightStyle
    let title: String
    let description: String
}

enum ProfileDescriptionInsightStyle: Equatable {
    case sun
    case moon
    case ascendant
    case dominantElement
    case weakElement
    case synthesis
}
