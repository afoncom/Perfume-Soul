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
        requestManager: RequestManager
    ) -> (screen: DailyPerfumeScreen, presenter: DailyPerfumePresenter) {
        let viewModel = DailyPerfumeViewModel()
        let presenter = DailyPerfumePresenterImpl(
            viewModel: viewModel,
            router: DailyPerfumeRouterImpl(navigationController: navigationController),
            service: DailyPerfumeServiceImpl(requestManager: requestManager),
            stateStorage: DailyPerfumeStateStorageImpl(userDefaults: .standard),
            dayKeyProvider: DailyPerfumeDayKeyProviderImpl(),
            selectionService: DailyPerfumeSelectionServiceImpl(
                randomSource: SystemDailyPerfumeRandomSource()
            )
        )

        return (
            screen: DailyPerfumeScreen(viewModel: viewModel, presenter: presenter),
            presenter: presenter
        )
    }
}
