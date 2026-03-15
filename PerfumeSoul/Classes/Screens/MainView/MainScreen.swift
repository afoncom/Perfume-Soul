//
//  MainScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var viewModel: MainViewModel
    private let presenter: MainPresenter
    
    init(
        viewModel: MainViewModel,
        presenter: MainPresenter
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.presenter = presenter
    }
    
    var body: some View {
        Text("MainScreen")
    }
}

extension MainScreen {
    
}
