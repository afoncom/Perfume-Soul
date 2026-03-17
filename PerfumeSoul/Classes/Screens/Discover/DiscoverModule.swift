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
        let view = DiscoverScreen()
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.view.backgroundColor = .systemBackground
        hostingController.tabBarItem = UITabBarItem.init(title: "Discover", image: nil, tag: 1)
        hostingController.title = "Discover"
        return hostingController
    }
}
