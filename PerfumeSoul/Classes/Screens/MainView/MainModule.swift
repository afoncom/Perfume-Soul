//
//  MainModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

final class MainModule {
    static func build() -> UIViewController {
        let viewModel = MainViewModel()
        let router = MainRouterImpl(navigationController: nil)
        let presenter = MainPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = MainScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.view.backgroundColor = .systemBackground
        hostingController.tabBarItem = UITabBarItem.init(title: "Main", image: nil, tag: 0)
        return hostingController
    }
}
