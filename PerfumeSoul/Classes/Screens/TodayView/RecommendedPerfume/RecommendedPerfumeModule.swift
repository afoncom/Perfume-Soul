//
//  RecommendedPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import UIKit

final class RecommendedPerfumeModule {
    static func build(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        profileService: ProfileService,
        collectionService: PerfumeCollectionService
    ) -> RecommendedPerfumeScreen {
        let viewModel = RecommendedPerfumeViewModel()
        let presenter = RecommendedPerfumePresenterImpl(
            viewModel: viewModel,
            service: RecommendedPerfumeServiceImpl(requestManager: requestManager),
            profileService: profileService,
            collectionService: collectionService,
            topStorage: PersonalPerfumeTopStorageImpl(userDefaults: .standard),
            stateStorage: RecommendedPerfumeStateStorageImpl(userDefaults: .standard),
            router: RecommendedPerfumeRouterImpl(navigationController: navigationController)
        )
        return RecommendedPerfumeScreen(viewModel: viewModel, presenter: presenter)
    }
}
