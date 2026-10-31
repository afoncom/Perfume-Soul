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
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader,
        onProfileSetupRequested: @escaping (Profile?) -> Void
    ) -> NavigationControllerContainer {
        let viewModel = ProfileViewModel()
        let navigationController = UINavigationController()
        let profileService = ProfileServiceImpl(container: container)
        let profileCalculationService = ProfileCalculationServiceImpl(requestManager: requestManager)
        let dayKeyProvider = QuizDayKeyProviderImpl()
        let quizProgressService = QuizProgressServiceImpl(
            container: container,
            dayKeyProvider: dayKeyProvider
        )
        let dailyQuizStateStorage = ViewStateStorage<DailyQuizState>(
            userDefaults: .standard,
            storableKey: "quiz.dailyState"
        )
        let dailyPerfumeStateStorage = ViewStateStorage<DailyPerfumeState>(
            userDefaults: .standard,
            storableKey: "dailyPerfume.state"
        )
        let collectionService = PerfumeCollectionServiceImpl(
            storage: PerfumeCollectionStorageImpl(
                userDefaults: .standard
            )
        )
        let personalPerfumeTopStorage = PersonalPerfumeTopStorageImpl(userDefaults: .standard)
        let recommendedPerfumeStateStorage = ViewStateStorage<RecommendedPerfumeState>(
            userDefaults: .standard,
            storableKey: "recommendedPerfume.state"
        )
        let appVersionProvider = AppVersionProviderImpl()
        let appReviewRequester = AppReviewRequesterImpl(
            userDefaults: .standard,
            appVersionProvider: appVersionProvider
        )
        let profileAvatarBuilder = ProfileAvatarBuilderImpl()
        let router = ProfileRouterImpl(
            navigationController: navigationController,
            container: container,
            requestManager: requestManager,
            imageLoader: imageLoader,
            onProfileSetupRequested: onProfileSetupRequested
        )
        let presenter = ProfilePresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: profileService,
            profileCalculationService: profileCalculationService,
            quizProgressService: quizProgressService,
            dailyQuizStateStorage: dailyQuizStateStorage,
            dailyPerfumeStateStorage: dailyPerfumeStateStorage,
            collectionService: collectionService,
            personalPerfumeTopStorage: personalPerfumeTopStorage,
            recommendedPerfumeStateStorage: recommendedPerfumeStateStorage,
            appReviewRequester: appReviewRequester,
            profileAvatarBuilder: profileAvatarBuilder,
            catalogFavoritesStorage: CatalogFavoritesStorage(userDefaults: .standard)
        )
        
        let view = ProfileScreen(
            viewModel: viewModel,
            presenter: presenter
        )
        
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.Screen.profile
        
        navigationController.viewControllers = [hostingController]
        navigationController.navigationBar.prefersLargeTitles = true
        
        return NavigationControllerContainer(navigationController: navigationController)
    }
}
