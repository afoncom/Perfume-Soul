//
//  ProfileModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import CoreData

final class ProfileModule {
    static func build(
        container: NSPersistentContainer,
        onProfileDeleted: @escaping () -> Void
    ) -> NavigationControllerContainer {
        let viewModel = ProfileViewModel()
        let navigationController = UINavigationController()
        let profileService = ProfileServiceImpl(container: container)
        let dayKeyProvider = QuizDayKeyProviderImpl()
        let quizProgressService = QuizProgressServiceImpl(
            userDefaults: .standard,
            dayKeyProvider: dayKeyProvider
        )
        let dailyQuizStateStorage = DailyQuizStateStorageImpl(userDefaults: .standard)
        let router = ProfileRouterImpl(
            navigationController: navigationController,
            container: container,
            onProfileDeleted: onProfileDeleted
        )
        let presenter = ProfilePresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService,
            quizProgressService: quizProgressService,
            dailyQuizStateStorage: dailyQuizStateStorage
        )
        
        let view = ProfileScreen(viewModel: viewModel, presenter: presenter)
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.profile
        
        navigationController.viewControllers = [hostingController]
        navigationController.navigationBar.prefersLargeTitles = true
        
        return NavigationControllerContainer(navigationController: navigationController)
    }
}
