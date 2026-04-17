//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol CalculationPresenter {
    func continueButtonTapped()
    func birthPlaceDidChange(_ query: String) async
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
        let profile = Profile(
            name: viewModel.firstName,
            birthDate: viewModel.formattedBirthDate,
            birthTime: viewModel.formattedBirthTime,
            birthPlace: viewModel.birthPlace
        )
        profileService.saveProfile(profile)
        router.showProfileDescription()
    }
    
    func birthPlaceDidChange(_ query: String) async {
        let completions = await birthPlaceSearch.search(query)
        await MainActor.run {
            viewModel.birthPlaceCompletions = completions
        }
    }
    
    @MainActor
    func clearBirthPlaceSearch() {
        viewModel.birthPlaceCompletions = []
        birthPlaceSearch.clear()
    }
}
