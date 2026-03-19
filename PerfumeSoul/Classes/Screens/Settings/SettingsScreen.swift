//
//  SettingsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct SettingsScreen: View {
    @Bindable var viewModel: SettingsViewModel
    private let presenter: SettingsPresenter
    
    init(
        viewModel: SettingsViewModel,
        presenter: SettingsPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text("Settings")
    }
}

extension SettingsScreen {
    
}
