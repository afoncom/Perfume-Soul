//
//  PerfumeCollectionState.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import Foundation

enum PerfumeCollectionSource: String, Codable, Equatable {
    case dailyPerfume
    case manual
}

struct PerfumeCollectionPerfume: Codable, Equatable, Identifiable {
    let id: Int
    let perfumeName: String
    let brandName: String
    let source: PerfumeCollectionSource?
}

struct PerfumeCollectionState: Codable, Equatable {
    var savedPerfumes: [PerfumeCollectionPerfume]
    var dislikedPerfumeIDs: [Int]

    static let empty = PerfumeCollectionState(savedPerfumes: [], dislikedPerfumeIDs: [])
}
