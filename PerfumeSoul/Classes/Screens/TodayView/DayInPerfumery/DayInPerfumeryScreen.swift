//
//  DayInPerfumeryScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct DayInPerfumeryScreen: View {
    @Bindable private var viewModel: DayInPerfumeryViewModel
    private let presenter: DayInPerfumeryPresenter
    
    init(
        viewModel: DayInPerfumeryViewModel,
        presenter: DayInPerfumeryPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text(L10n.Screen.dayInPerfumery)
    }
}

extension DayInPerfumeryScreen {
    
}
