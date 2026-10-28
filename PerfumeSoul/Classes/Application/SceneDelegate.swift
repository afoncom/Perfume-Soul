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

    static func backendBaseURL(environment: [String: String]) -> String {
        let defaultURL = "http://82.97.248.219"
        guard let override = environment["PERFUME_SOUL_BACKEND_URL"],
            let url = URL(string: override),
            let scheme = url.scheme,
            ["http", "https"].contains(scheme),
            url.host != nil else {
            return defaultURL
        }
        var baseURL = override
        while baseURL.hasSuffix("/") {
            baseURL.removeLast()
        }
        return baseURL
    }

    private lazy var requestManager: RequestManager = RequestManagerImpl(
        urlSession: URLSession.shared,
        baseURL: Self.backendBaseURL(environment: ProcessInfo.processInfo.environment)
    )
    
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
        let todayScreen = TodayModule.build(
            container: container,
            requestManager: requestManager
        )
        let settingsScreen = SettingsModule.build(
            container: container
        )
        let discoverScreen = DiscoverModule.build(
            container: container,
            requestManager: requestManager
        )
        let profileScreen = ProfileModule.build(
            container: container,
            requestManager: requestManager
        ) { [weak self] initialProfile in
            self?.showCalculationScreen(container: container, initialProfile: initialProfile)
        }
        let searchPerfumeScreen = SearchPerfumeModule.build(requestManager: requestManager)
        
        let mainTabView = MainTabView(
            todayScreen: todayScreen,
            discoverScreen: discoverScreen,
            profileScreen: profileScreen,
            settingsScreen: settingsScreen,
            searchPerfumeScreen: searchPerfumeScreen
        )
        let viewController = UIHostingController(rootView: mainTabView)
        setRootViewController(viewController)
    }

    private func showCalculationScreen(
        container: NSPersistentContainer,
        initialProfile: Profile? = nil
    ) {
        let calculationScreen = CalculationModule.build(
            container: container,
            requestManager: requestManager,
            initialProfile: initialProfile
        ) { [weak self] in
            self?.finishCalculationFlow()
        }
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
