//
//  DayInPerfumeryPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol DayInPerfumeryPresenter {
    
}

final class DayInPerfumeryPresenterImpl {
    private let viewModel: DayInPerfumeryViewModel
    private let router: DayInPerfumeryRouter
    
    init(
        viewModel: DayInPerfumeryViewModel,
        router: DayInPerfumeryRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension DayInPerfumeryPresenterImpl: DayInPerfumeryPresenter {
    
}
