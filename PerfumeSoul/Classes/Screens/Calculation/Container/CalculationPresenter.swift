//
//  CalculationPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol CalculationPresenter {
    func continueButtonTapped()
    func birthPlaceDidChange(_ query: String)
    func clearBirthPlaceSearch()
}

final class CalculationPresenterImpl {
    private let viewModel: CalculationViewModel
    private let router: CalculationRouter
    private let profileService: ProfileService
    private let birthPlaceSearch: BirthPlaceSearchService
    private var birthPlaceSearchTask: Task<Void, Never>?
    
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
        router.finishCalculation()
    }
    
    func birthPlaceDidChange(_ query: String) {
        birthPlaceSearchTask?.cancel()
        birthPlaceSearchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let completions = await birthPlaceSearch.search(query)
            
            guard !Task.isCancelled else { return }
            
            viewModel.birthPlaceCompletions = completions
        }
    }
    
    func clearBirthPlaceSearch() {
        birthPlaceSearchTask?.cancel()
        birthPlaceSearchTask = nil
        viewModel.birthPlaceCompletions = []
        birthPlaceSearch.clear()
    }
}
