//
//  DailyPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//

import SwiftUI
import UIKit

final class DailyPerfumeModule {
    static func build(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        profileService: ProfileService,
        collectionService: PerfumeCollectionService
    ) -> DailyPerfumeScreen {
        let viewModel = DailyPerfumeViewModel()
        let presenter = DailyPerfumePresenterImpl(
            viewModel: viewModel,
            router: DailyPerfumeRouterImpl(
                navigationController: navigationController,
                requestManager: requestManager
            ),
            service: DailyPerfumeServiceImpl(requestManager: requestManager),
            profileService: profileService,
            stateStorage: DailyPerfumeStateStorageImpl(userDefaults: .standard),
            collectionService: collectionService,
            dayKeyProvider: DailyPerfumeDayKeyProviderImpl(),
            selectionService: DailyPerfumeSelectionServiceImpl(
                randomSource: SystemDailyPerfumeRandomSource()
            )
        )

        return DailyPerfumeScreen(viewModel: viewModel, presenter: presenter)
    }
}
