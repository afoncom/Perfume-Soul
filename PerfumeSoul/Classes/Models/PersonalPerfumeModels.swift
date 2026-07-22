//
//  PersonalPerfumeModels.swift
//  PerfumeSoul
//
//  Created by afon.com on 17.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

struct PersonalPerfumeItem {
    let name: String
    let subtitle: String
    let matchExplanation: String?
    let matchPercentage: Int
}

struct PersonalPerfumeSection {
    let title: String
    let perfumes: [PersonalPerfumeItem]
    let description: String
}
