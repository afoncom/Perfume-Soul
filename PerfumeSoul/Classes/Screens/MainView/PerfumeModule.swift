//
//  PerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import SwiftUI

final class PerfumeModule {
    static func build() -> UIViewController {
        let viewModel = PerfumeViewModel()
        let router = PerfumeRouterImpl(navigationController: nil)
        let presenter = PerfumePresenterImpl(
            viewModel: viewModel,
            router: router
        )
        
        let view = PerfumeScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.view.backgroundColor = .systemBackground
        hostingController.tabBarItem = UITabBarItem.init(title: "Main", image: nil, tag: 0)
        return hostingController
    }
}
