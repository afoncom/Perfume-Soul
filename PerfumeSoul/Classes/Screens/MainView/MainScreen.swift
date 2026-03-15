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
        VStack {
            switch viewModel.viewState {
            case .loading:
                ProgressView()
            case .loaded:
                Text(verbatim: "loaded")
            case .error:
                Text(verbatim: "Error")
            }
        }

        
    }
}

extension MainScreen {
    
}

extension MainScreen {
    enum ViewState {
        case loading
        case loaded
        case error
    }
}
