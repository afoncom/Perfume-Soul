//
//  TodayModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

final class TodayModule {
    static func build() -> UIViewController {
        let viewModel = TodayViewModel()
        let navigationController = UINavigationController()
        let router = TodayRouterImpl(navigationController: navigationController)
        let presenter = TodayPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = TodayScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = "Today"

        navigationController.viewControllers = [hostingController]
        navigationController.tabBarItem = UITabBarItem(title: "Today", image: nil, tag: 0)
        
        return navigationController
    }
}
