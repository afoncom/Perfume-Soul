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
    @discardableResult
    func birthPlaceSuggestionTapped(_ suggestion: BirthPlaceSuggestion) async -> Bool
}

final class CalculationPresenterImpl {
    private let viewModel: CalculationViewModel
    private let router: CalculationRouter
    private let profileService: ProfileService
    private let birthPlaceSearch: BirthPlaceSearching
    
    init(
        viewModel: CalculationViewModel,
        router: CalculationRouter,
        profileService: ProfileService,
        birthPlaceSearch: BirthPlaceSearching
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
        let isAlreadySelected = await MainActor.run {
            viewModel.selectedBirthPlace?.displayName == searchQuery
        }

        guard !isAlreadySelected else {
            await MainActor.run {
                viewModel.activeBirthPlaceSearchQuery = searchQuery
            }
            return
        }

        await MainActor.run {
            viewModel.selectedBirthPlace = nil
            viewModel.birthPlaceErrorMessage = nil
            viewModel.canRetryBirthPlaceSearch = false
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
                viewModel.canRetryBirthPlaceSearch = false
            case let .timedOut(suggestions):
                viewModel.birthPlaceSuggestions = suggestions
                if suggestions.isEmpty {
                    viewModel.activeBirthPlaceSearchQuery = ""
                    viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSearchError
                    viewModel.canRetryBirthPlaceSearch = true
                } else {
                    viewModel.canRetryBirthPlaceSearch = false
                }
            case .failed:
                viewModel.birthPlaceSuggestions = []
                viewModel.activeBirthPlaceSearchQuery = ""
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSearchError
                viewModel.canRetryBirthPlaceSearch = true
            }
        }
    }

    @discardableResult
    func birthPlaceSuggestionTapped(_ suggestion: BirthPlaceSuggestion) async -> Bool {
        let (previousSuggestions, requestQuery) = await MainActor.run { () -> ([BirthPlaceSuggestion], String) in
            let suggestions = viewModel.birthPlaceSuggestions
            viewModel.birthPlaceSuggestions = []
            viewModel.birthPlaceErrorMessage = nil
            viewModel.canRetryBirthPlaceSearch = false
            viewModel.isSearchingBirthPlace = true
            return (suggestions, viewModel.activeBirthPlaceSearchQuery)
        }

        do {
            let selection = try await birthPlaceSearch.resolve(suggestion)

            let didApplySelection = await MainActor.run { () -> Bool in
                guard viewModel.activeBirthPlaceSearchQuery == requestQuery else {
                    return false
                }

                viewModel.birthPlace = selection.displayName
                viewModel.selectedBirthPlace = selection
                viewModel.birthPlaceSuggestions = []
                viewModel.activeBirthPlaceSearchQuery = ""
                viewModel.isSearchingBirthPlace = false
                viewModel.birthPlaceErrorMessage = nil
                viewModel.canRetryBirthPlaceSearch = false
                return true
            }

            guard didApplySelection else {
                return false
            }

            await birthPlaceSearch.clear()
            return true
        } catch BirthPlaceSearchError.missingDisplayName, BirthPlaceSearchError.missingTimeZone {
            return await MainActor.run { () -> Bool in
                guard viewModel.activeBirthPlaceSearchQuery == requestQuery else {
                    return false
                }

                viewModel.selectedBirthPlace = nil
                viewModel.birthPlaceSuggestions = previousSuggestions
                viewModel.isSearchingBirthPlace = false
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceUnresolvedError
                viewModel.canRetryBirthPlaceSearch = false
                return true
            }
        } catch {
            return await MainActor.run { () -> Bool in
                guard viewModel.activeBirthPlaceSearchQuery == requestQuery else {
                    return false
                }

                viewModel.selectedBirthPlace = nil
                viewModel.birthPlaceSuggestions = previousSuggestions
                viewModel.isSearchingBirthPlace = false
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSelectionError
                viewModel.canRetryBirthPlaceSearch = false
                return true
            }
        }
    }
}
