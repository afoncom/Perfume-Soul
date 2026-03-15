//
//  ProfilePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol ProfilePresenter {
    
}

final class ProfilePresenterImpl {
    private let viewModel: ProfileViewMoodel
    private let router: ProfileRouter
    
    init(
        viewModel: ProfileViewMoodel,
        router: ProfileRouter
    ) {
        self.viewModel = viewModel
        self.router = router
    }
}

extension ProfilePresenterImpl: ProfilePresenter {
    

}
