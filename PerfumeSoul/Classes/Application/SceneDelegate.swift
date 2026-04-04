//
//  SceneDelegate.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit
import SwiftUI
import CoreData

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private enum Constants {
        static let hasCompletedCalculationKey = "hasCompletedCalculation"
    }
    
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
        
        if UserDefaults.standard.bool(forKey: Constants.hasCompletedCalculationKey) {
            showMainScreen(container: coreDataManager.container)
        } else {
            showCalculationScreen(container: coreDataManager.container)
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        coreDataManager.saveContext()
    }

    private func showMainScreen(container: NSPersistentContainer) {
        let todayScreen = TodayModule.build()
        let settingsScreen = SettingsModule.build()
        let discoverScreen = DiscoverModule.build()
        let profileScreen = ProfileModule.build(container: container)
        let tabController = UITabBarController()
        tabController.viewControllers = [todayScreen, discoverScreen, profileScreen, settingsScreen]
        setRootViewController(tabController)
    }

    private func showCalculationScreen(container: NSPersistentContainer) {
        let calculationScreen = CalculationModule.build(
            container: container,
            onFinish: { [weak self] in
                self?.finishCalculationFlow()
            }
        )
        setRootViewController(calculationScreen)
    }

    private func finishCalculationFlow() {
        UserDefaults.standard.set(true, forKey: Constants.hasCompletedCalculationKey)
        showMainScreen(container: coreDataManager.container)
    }
    
    private func setRootViewController(_ viewController: UIViewController) {
        guard let window else {
            return
        }

        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
