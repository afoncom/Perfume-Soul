//
//  PerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct PerfumeScreen: View {
    @StateObject private var viewModel: PerfumeViewModel
    private let presenter: PerfumePresenter
    
    init(
        viewModel: PerfumeViewModel,
        presenter: PerfumePresenter
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.presenter = presenter
    }
    
    var body: some View {
        Text("MainScreen")
    }
}

extension PerfumeScreen {
    
}
