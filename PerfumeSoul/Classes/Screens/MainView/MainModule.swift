//
//  MainModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

final class MainModule {
    static func build() -> MainScreen {
        let viewModel = MainViewModel()
        let router = MainRouterImpl(navigationController: nil)
        let presenter = MainPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = MainScreen(viewModel: viewModel, presenter: presenter)
        return view
    }
}
