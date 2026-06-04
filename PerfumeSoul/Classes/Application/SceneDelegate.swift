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
        window.backgroundColor = UIColor(resource: .backgroundPrimary)
        self.window = window

        showWelcomeLoadingScreen(container: coreDataManager.container)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        coreDataManager.saveContext()
    }

    private func showWelcomeLoadingScreen(container: NSPersistentContainer) {
        let welcomeLoadingScreen = WelcomeLoadingModule.build(
            container: container,
            onProfileExists: { [weak self] in
                self?.showMainScreen(container: container)
            },
            onProfileMissing: { [weak self] in
                self?.showCalculationScreen(container: container)
            }
        )
        setRootViewController(welcomeLoadingScreen)
    }

    private func showMainScreen(container: NSPersistentContainer) {
        let todayScreen = TodayModule.build(container: container)
        let settingsScreen = SettingsModule.build()
        let discoverScreen = DiscoverModule.build(container: container)
        let profileScreen = ProfileModule.build(
            container: container,
            onProfileDeleted: { [weak self] in
                self?.showCalculationScreen(container: container)
            }
        )
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
