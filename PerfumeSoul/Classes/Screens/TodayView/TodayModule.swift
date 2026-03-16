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
        let router = TodayRouterImpl()
        let presenter = TodayPresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = TodayScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Today"

        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.tabBarItem = UITabBarItem(title: "Today", image: nil, tag: 0)
        router.navigationController = navigationController
        
        return navigationController
    }
}
