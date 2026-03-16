//
//  SettingsModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class SettingsModule {
    static func build() -> UIViewController {
        let router = SettingsRouterImpl()
        let view = SettingsScreen()
        
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.title = "Settings"
        
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.tabBarItem = UITabBarItem(title: "Settings", image: nil, tag: 3)
        router.navigationController = navigationController
        
        return navigationController
    }
}
