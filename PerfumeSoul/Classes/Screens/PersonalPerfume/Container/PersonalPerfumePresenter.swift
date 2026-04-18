//
//  PersonalPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PersonalPerfumePresenter {
    func viewDidLoad()
    func continueButtonTapped()
}

final class PersonalPerfumePresenterImpl {
    private let viewModel: PersonalPerfumeViewModel
    private let router: PersonalPerfumeRouter
    private let service: PersonalPerfumeService
    
    init(
        viewModel: PersonalPerfumeViewModel,
        router: PersonalPerfumeRouter,
        service: PersonalPerfumeService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
    }
}

extension PersonalPerfumePresenterImpl: PersonalPerfumePresenter {
    func viewDidLoad() {
        viewModel.sections = service.fetchSections()
    }

    func continueButtonTapped() {
        router.finishOnboarding()
    }
}
