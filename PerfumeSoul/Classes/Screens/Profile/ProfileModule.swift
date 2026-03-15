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
        let view = ProfileScreen()
        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.view.backgroundColor = .systemBackground
        hostingController.tabBarItem = UITabBarItem.init(title: "Profile", image: nil, tag: 1)
        return hostingController
    }
}
