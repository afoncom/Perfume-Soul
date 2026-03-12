//
//  SceneDelegate.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        self.window = window

        showMainScreen()
    }

    private func showMainScreen() {
        let mainView = MainModule.build()
        setRootView(mainView)
    }

    private func setRootView<V: View>(_ view: V) {
        guard let window else {
            return
        }

        let hostingController = UIHostingController(rootView: AnyView(view.ignoresSafeArea()))
        hostingController.view.backgroundColor = .systemBackground
        window.rootViewController = hostingController
        window.makeKeyAndVisible()
    }
}
