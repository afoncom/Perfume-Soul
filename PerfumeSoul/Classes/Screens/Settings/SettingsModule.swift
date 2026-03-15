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
        let view = SettingsScreen()
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.view.backgroundColor = .systemBackground
        hostingController.tabBarItem = UITabBarItem.init(title: "Settings", image: nil, tag: 2)
        return hostingController
    }
}
