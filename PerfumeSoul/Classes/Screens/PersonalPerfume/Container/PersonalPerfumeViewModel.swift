//
//  PersonalPerfumeViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Observation

@Observable final class PersonalPerfumeViewModel {
    struct PerfumeItem {
        let name: String
        let subtitle: String
    }
    
    struct PerfumeSection {
        let title: String
        let perfumes: [PerfumeItem]
        let description: String
    }
    
    let sections: [PerfumeSection] = [
        PerfumeSection(
            title: "Luxury Picks",
            perfumes: [
                PerfumeItem(name: "Initio", subtitle: "Oud for Greatness"),
                PerfumeItem(name: "Kilian", subtitle: "Angels' Share"),
                PerfumeItem(name: "Tom Ford", subtitle: "Soleil Blanc")
            ],
            description: "Oud, saffron, and patchouli create a deep, mysterious aura."
        ),
        PerfumeSection(
            title: "Daily Picks",
            perfumes: [
                PerfumeItem(name: "Chanel", subtitle: "Coco Mademoiselle"),
                PerfumeItem(name: "Dior", subtitle: "Sauvage"),
                PerfumeItem(name: "Byredo", subtitle: "Mojave Ghost")
            ],
            description: "Fresh spices and amberwood suit your bold, confident vibe."
        ),
        PerfumeSection(
            title: "Affordable Picks",
            perfumes: [
                PerfumeItem(name: "Montblanc", subtitle: "Explorer"),
                PerfumeItem(name: "Zara", subtitle: "Vibrant Leather"),
                PerfumeItem(name: "Lattafa", subtitle: "Khamrah")
            ],
            description: "Bergamot and warm woods give a refined effect with an easy mood."
        )
    ]
}
