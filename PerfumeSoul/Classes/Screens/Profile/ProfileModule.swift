//
//  ProfileModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class ProfileModule {
    static func build() -> UIViewController {
        let viewModel = ProfileViewMoodel()
        let router = ProfileRouterImpl()
        let view = ProfileScreen(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Profile"
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.tabBarItem = UITabBarItem(title: "Profile", image: nil, tag: 2)
        router.navigationController = navigationController
        
        return navigationController
    }
}
