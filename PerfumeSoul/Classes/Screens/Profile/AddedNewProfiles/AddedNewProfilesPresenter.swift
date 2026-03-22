//
//  AddedNewProfilesPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol AddedNewProfilesPresenter {
    
}

final class AddedNewProfilesPresenterImpl {
    private let viewModel: AddedNewProfilesViewModel
    private let router: AddedNewProfilesRouter
    
    init(
        viewModel: AddedNewProfilesViewModel,
        router: AddedNewProfilesRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension AddedNewProfilesPresenterImpl: AddedNewProfilesPresenter {
    
}
