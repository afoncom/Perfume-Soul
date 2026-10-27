//
//  SearchPerfumeViewModel.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation
import Observation

enum CatalogTab: CaseIterable {
    case perfumes
    case brands
    case saved

    var title: String {
        switch self {
        case .perfumes: return String(localized: "catalog.perfumes")
        case .brands: return String(localized: "catalog.brands")
        case .saved: return String(localized: "catalog.saved")
        }
    }
}

struct CatalogBrandSection: Equatable {
    let title: String
    let brands: [CatalogBrand]
}

@Observable final class SearchPerfumeViewModel {
    var searchText = ""
    var tab: CatalogTab = .perfumes
    var showsSavedBrands = false
    var selectedBrand: CatalogBrand?
    var perfumes: [CatalogPerfume] = []
    var brands: [CatalogBrand] = []
    var savedPerfumes: [PerfumeCollectionPerfume] = []
    var favoriteBrandIDs: Set<Int> = []
    var errorMessage: String?
    var brandsErrorMessage: String?
    var isLoading = false
    var isLoadingMore = false
    var isLoadingBrands = false
    var hasLoadedOnce = false
    var hasLoadedBrands = false
    var canLoadMore = false

    var isShowingBrands: Bool {
        tab == .brands || (tab == .saved && showsSavedBrands)
    }

    var query: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var savedIDs: Set<Int> {
        Set(savedPerfumes.map(\.id))
    }

    var displayedPerfumes: [CatalogPerfume] {
        guard tab == .saved else {
            return perfumes
        }
        return savedPerfumes
            .filter { query.isEmpty || $0.perfumeName.localizedStandardContains(query) || $0.brandName.localizedStandardContains(query) }
            .map { CatalogPerfume(id: $0.id, name: $0.perfumeName, brand: $0.brandName, brandID: nil, imageURL: $0.imageURL) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var brandSections: [CatalogBrandSection] {
        let filtered = brands.filter {
            (tab != .saved || favoriteBrandIDs.contains($0.id)) &&
                (query.isEmpty || $0.name.localizedStandardContains(query))
        }
        let grouped = Dictionary(grouping: filtered) { brand -> String in
            let name = brand.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: .diacriticInsensitive, locale: .current)
            guard let first = name.first, first.isLetter else {
                return "#"
            }
            return String(first).uppercased()
        }
        return grouped.keys
            .sorted {
                if $0 == "#" {
                    return false
                }
                if $1 == "#" {
                    return true
                }
                return $0.localizedStandardCompare($1) == .orderedAscending
            }
            .map { title in
                CatalogBrandSection(
                    title: title,
                    brands: (grouped[title] ?? []).sorted {
                        $0.name.localizedStandardCompare($1.name) == .orderedAscending
                    }
                )
            }
    }

    var emptyMessage: String {
        if !query.isEmpty {
            return String(localized: "catalog.noResults")
        }
        if tab == .saved {
            return showsSavedBrands
                ? String(localized: "catalog.emptyBrands")
                : String(localized: "catalog.emptySaved")
        }
        return String(localized: "catalog.noResults")
    }
}
