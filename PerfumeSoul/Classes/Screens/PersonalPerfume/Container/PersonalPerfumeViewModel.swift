//
//  PersonalPerfumeViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

struct PersonalPerfumeItem {
    let name: String
    let subtitle: String
}

struct PersonalPerfumeSection {
    let title: String
    let perfumes: [PersonalPerfumeItem]
    let description: String
}

enum PersonalPerfumeContent {
    static let sections: [PersonalPerfumeSection] = [
        PersonalPerfumeSection(
            title: "Luxury Picks",
            perfumes: [
                PersonalPerfumeItem(name: "Initio", subtitle: "Oud for Greatness"),
                PersonalPerfumeItem(name: "Kilian", subtitle: "Angels' Share"),
                PersonalPerfumeItem(name: "Tom Ford", subtitle: "Soleil Blanc")
            ],
            description: "Oud, saffron, and patchouli create a deep, mysterious aura."
        ),
        PersonalPerfumeSection(
            title: "Daily Picks",
            perfumes: [
                PersonalPerfumeItem(name: "Chanel", subtitle: "Coco Mademoiselle"),
                PersonalPerfumeItem(name: "Dior", subtitle: "Sauvage"),
                PersonalPerfumeItem(name: "Byredo", subtitle: "Mojave Ghost")
            ],
            description: "Fresh spices and amberwood suit your bold, confident vibe."
        ),
        PersonalPerfumeSection(
            title: "Affordable Picks",
            perfumes: [
                PersonalPerfumeItem(name: "Montblanc", subtitle: "Explorer"),
                PersonalPerfumeItem(name: "Zara", subtitle: "Vibrant Leather"),
                PersonalPerfumeItem(name: "Lattafa", subtitle: "Khamrah")
            ],
            description: "Bergamot and warm woods give a refined effect with an easy mood."
        )
    ]
}

@Observable final class PersonalPerfumeViewModel {
    let sections = PersonalPerfumeContent.sections
}
