//
//  ProfileScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ProfileScreen: View {
    @Bindable private var viewModel: ProfileViewMoodel
    private let presenter: ProfilePresenter
    
    init(
        viewModel: ProfileViewMoodel,
        presenter: ProfilePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("Profile")
        
        Button("AddedNewProfiles") {
            presenter.addedNewProfilesButtonTab()
        }
    }
}

extension ProfileScreen {
    
}
