//
//  SceneDelegate.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let coreDataManager: CoreDataManager = CoreDataManagerImpl()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        coreDataManager.initContainer()
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .systemBackground
        self.window = window

        showMainScreen()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        coreDataManager.saveContext()
    }

    private func showMainScreen() {
        let todayScreen = TodayModule.build()
        let settingsScreen = SettingsModule.build()
        let discoverScreen = DiscoverModule.build()
        let profileScreen = ProfileModule.build()
        let tabController = UITabBarController()
        tabController.viewControllers = [todayScreen, discoverScreen, profileScreen, settingsScreen]
        setRootViewController(tabController)
    }
    

    private func setRootViewController(_ viewController: UIViewController) {
        guard let window else {
            return
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
    
}
