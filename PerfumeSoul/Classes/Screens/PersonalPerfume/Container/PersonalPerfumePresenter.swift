//
//  PersonalPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PersonalPerfumePresenter {
    var shouldShowContinueButton: Bool { get }

    @MainActor
    func onAppear()
    func continueButtonTapped()
}

final class PersonalPerfumePresenterImpl {
    private let viewModel: PersonalPerfumeViewModel
    private let router: PersonalPerfumeRouter
    private let service: PersonalPerfumeService
    let shouldShowContinueButton: Bool
    
    init(
        viewModel: PersonalPerfumeViewModel,
        router: PersonalPerfumeRouter,
        service: PersonalPerfumeService,
        shouldShowContinueButton: Bool
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
        self.shouldShowContinueButton = shouldShowContinueButton
    }
}

extension PersonalPerfumePresenterImpl: PersonalPerfumePresenter {
    func onAppear() {
        viewModel.sections = service.fetchSections()
    }

    func continueButtonTapped() {
        router.finishOnboarding()
    }
}
