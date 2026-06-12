//
//  SearchPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct SearchPerfumeScreen: View {
    @Bindable private var viewModel: SearchPerfumeViewModel
    private let presenter: SearchPerfumePresenter
    
    init(
        viewModel: SearchPerfumeViewModel,
        presenter: SearchPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        Text(L10n.Screen.searchPerfume)
    }
}

extension SearchPerfumeScreen {
    
}
