//
//  SettingsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol SettingsPresenter {
    
}

final class SettingsPresenterImpl {
    private let viewModel: SettingsViewModel
    private let router: SettingsRouter
    
    init(
        viewModel: SettingsViewModel,
        router: SettingsRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension SettingsPresenterImpl: SettingsPresenter {
    

}
