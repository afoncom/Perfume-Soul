//
//  AddedNewProfilesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct AddedNewProfilesScreen: View {
    @Bindable private var viewModel: AddedNewProfilesViewModel
    private let presenter: AddedNewProfilesPresenter
    
    init(
        viewModel: AddedNewProfilesViewModel,
        presenter: AddedNewProfilesPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text(L10n.Screen.addedProfiles)
    }
}

extension AddedNewProfilesScreen {
    
}
