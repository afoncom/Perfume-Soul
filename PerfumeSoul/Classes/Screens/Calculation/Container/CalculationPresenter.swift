//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import Foundation

protocol CalculationPresenter {
    func continueButtonTapped() async
    func birthPlaceDidChange(_ query: String) async
    func birthPlaceSuggestionTapped(_ suggestion: BirthPlaceSuggestion) async
}

final class CalculationPresenterImpl {
    private let viewModel: CalculationViewModel
    private let router: CalculationRouter
    private let profileService: ProfileService
    private let birthPlaceSearch: BirthPlaceSearchService
    
    init(
        viewModel: CalculationViewModel,
        router: CalculationRouter,
        profileService: ProfileService,
        birthPlaceSearch: BirthPlaceSearchService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.profileService = profileService
        self.birthPlaceSearch = birthPlaceSearch
    }
}

extension CalculationPresenterImpl: CalculationPresenter {
    func continueButtonTapped() async {
        guard let selectedBirthPlace = viewModel.selectedBirthPlace else {
            return
        }

        let profile = Profile(
            name: viewModel.firstName,
            birthDate: viewModel.formattedBirthDate,
            birthTime: viewModel.formattedBirthTime,
            birthPlace: selectedBirthPlace.displayName,
            birthLatitude: selectedBirthPlace.latitude,
            birthLongitude: selectedBirthPlace.longitude,
            birthTimeZoneIdentifier: selectedBirthPlace.timeZoneIdentifier
        )

        await profileService.replaceProfile(profile)
        await MainActor.run {
            router.showProfileDescription()
        }
    }
    
    func birthPlaceDidChange(_ query: String) async {
        let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        await MainActor.run {
            if viewModel.selectedBirthPlace?.displayName != query {
                viewModel.selectedBirthPlace = nil
            }
            viewModel.birthPlaceErrorMessage = nil
            viewModel.birthPlaceSuggestions = []
            viewModel.isSearchingBirthPlace = true
            viewModel.activeBirthPlaceSearchQuery = searchQuery
        }

        let result = await birthPlaceSearch.search(query)
        await MainActor.run {
            guard viewModel.activeBirthPlaceSearchQuery == searchQuery else {
                return
            }

            viewModel.isSearchingBirthPlace = false
            switch result {
            case let .suggestions(suggestions):
                viewModel.birthPlaceSuggestions = suggestions
            case let .timedOut(suggestions):
                viewModel.birthPlaceSuggestions = suggestions
                if suggestions.isEmpty {
                    viewModel.activeBirthPlaceSearchQuery = ""
                    viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSelectionError
                }
            case .failed:
                viewModel.birthPlaceSuggestions = []
                viewModel.activeBirthPlaceSearchQuery = ""
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSelectionError
            }
        }
    }

    func birthPlaceSuggestionTapped(_ suggestion: BirthPlaceSuggestion) async {
        let previousSuggestions = await MainActor.run { () -> [BirthPlaceSuggestion] in
            let suggestions = viewModel.birthPlaceSuggestions
            viewModel.birthPlaceSuggestions = []
            viewModel.birthPlaceErrorMessage = nil
            viewModel.isSearchingBirthPlace = true
            return suggestions
        }

        do {
            let selection = try await birthPlaceSearch.resolve(suggestion)

            await MainActor.run {
                viewModel.birthPlace = selection.displayName
                viewModel.selectedBirthPlace = selection
                viewModel.birthPlaceSuggestions = []
                viewModel.isSearchingBirthPlace = false
                viewModel.birthPlaceErrorMessage = nil
            }

            await birthPlaceSearch.clear()
        } catch BirthPlaceSearchError.missingDisplayName, BirthPlaceSearchError.missingTimeZone {
            await MainActor.run {
                viewModel.selectedBirthPlace = nil
                viewModel.birthPlaceSuggestions = previousSuggestions
                viewModel.isSearchingBirthPlace = false
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceUnresolvedError
            }
        } catch {
            await MainActor.run {
                viewModel.selectedBirthPlace = nil
                viewModel.birthPlaceSuggestions = previousSuggestions
                viewModel.isSearchingBirthPlace = false
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSelectionError
            }
        }
    }
}
