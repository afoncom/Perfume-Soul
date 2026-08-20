//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol CalculationPresenter {
    func continueButtonTapped() async
    func birthPlaceDidChange(_ query: String) async
    func birthPlaceSuggestionTapped(_ suggestion: BirthPlaceSuggestion) async
    @MainActor
    func clearBirthPlaceSearch()
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
        await MainActor.run {
            if viewModel.selectedBirthPlace?.displayName != query {
                viewModel.selectedBirthPlace = nil
            }
            viewModel.birthPlaceErrorMessage = nil
        }

        let suggestions = await birthPlaceSearch.search(query)
        await MainActor.run {
            viewModel.birthPlaceSuggestions = suggestions
        }
    }

    func birthPlaceSuggestionTapped(_ suggestion: BirthPlaceSuggestion) async {
        do {
            let selection = try await birthPlaceSearch.resolve(suggestion)

            await MainActor.run {
                viewModel.birthPlace = selection.displayName
                viewModel.selectedBirthPlace = selection
                viewModel.birthPlaceSuggestions = []
                viewModel.birthPlaceErrorMessage = nil
            }

            await birthPlaceSearch.clear()
        } catch BirthPlaceSearchError.missingDisplayName, BirthPlaceSearchError.missingTimeZone {
            await MainActor.run {
                viewModel.selectedBirthPlace = nil
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceUnresolvedError
            }
        } catch {
            await MainActor.run {
                viewModel.selectedBirthPlace = nil
                viewModel.birthPlaceErrorMessage = L10n.Calculation.birthPlaceSelectionError
            }
        }
    }
    
    @MainActor
    func clearBirthPlaceSearch() {
        viewModel.birthPlaceSuggestions = []
        birthPlaceSearch.clear()
    }
}
