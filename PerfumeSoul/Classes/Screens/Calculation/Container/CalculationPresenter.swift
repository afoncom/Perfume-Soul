//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import MapKit

protocol CalculationPresenter {
    func continueButtonTapped()
    func birthPlaceDidChange(_ query: String) async
    func birthPlaceCompletionTapped(_ completion: MKLocalSearchCompletion) async
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
    func continueButtonTapped() {
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
        profileService.saveProfile(profile)
        router.showProfileDescription()
    }
    
    func birthPlaceDidChange(_ query: String) async {
        await MainActor.run {
            if viewModel.selectedBirthPlace?.displayName != query {
                viewModel.selectedBirthPlace = nil
            }
        }

        let completions = await birthPlaceSearch.search(query)
        await MainActor.run {
            viewModel.birthPlaceCompletions = completions
        }
    }

    func birthPlaceCompletionTapped(_ completion: MKLocalSearchCompletion) async {
        guard let selection = await birthPlaceSearch.resolve(completion) else {
            return
        }

        await MainActor.run {
            viewModel.birthPlace = selection.displayName
            viewModel.selectedBirthPlace = selection
            viewModel.birthPlaceCompletions = []
        }

        birthPlaceSearch.clear()
    }
    
    @MainActor
    func clearBirthPlaceSearch() {
        viewModel.birthPlaceCompletions = []
        birthPlaceSearch.clear()
    }
}
