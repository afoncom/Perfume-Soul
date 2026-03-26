//
//  SceneDelegate.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private enum Constants {
        static let hasCompletedCalculationKey = "hasCompletedCalculation"
    }
    
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

        showInitialScreen()
    }

    private func showInitialScreen() {
        if UserDefaults.standard.bool(forKey: Constants.hasCompletedCalculationKey) {
            showMainScreen()
        } else {
            showCalculationScreen()
        }
    }
    
    private func showCalculationScreen() {
        let calculationScreen = CalculationModule.build { [weak self] in
            self?.finishCalculationFlow()
        }
        setRootViewController(calculationScreen)
    }
    
    private func finishCalculationFlow() {
        UserDefaults.standard.set(true, forKey: Constants.hasCompletedCalculationKey)
        showMainScreen()
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
        let shouldAnimateTransition = window.rootViewController != nil
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        guard shouldAnimateTransition else {
            return
        }
        
        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
