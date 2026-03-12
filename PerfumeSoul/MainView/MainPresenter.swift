//
//  MainPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

protocol MainPresenter {
    
}

final class MainPresenterImpl {
    private let viewModel: MainViewModel
    private let router: MainRouter
    
    init(
        viewModel: MainViewModel,
        router: MainRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension MainPresenterImpl: MainPresenter {
    

}
