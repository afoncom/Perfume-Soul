//
//  DiscoverModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class DiscoverModule {
    static func build() -> UIViewController {
        let router = DiscoverRouterImpl()
        let view = DiscoverScreen()
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Discover"
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.tabBarItem = UITabBarItem(title: "Discover", image: nil, tag: 1)
        router.navigationController = navigationController

        return navigationController
    }
}
