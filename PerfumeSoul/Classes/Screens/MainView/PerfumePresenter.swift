//
//  PerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

protocol PerfumePresenter {
    
}

final class PerfumePresenterImpl {
    private let viewModel: PerfumeViewModel
    private let router: PerfumeRouter
    
    init(
        viewModel: PerfumeViewModel,
        router: PerfumeRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension PerfumePresenterImpl: PerfumePresenter {
    

}
