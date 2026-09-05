//
//  CabinetModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI
import UIKit

final class CabinetModule {
    @MainActor static func build(
        navigationController: UINavigationController?,
        stateStorage: DailyPerfumeStateStorage
    ) -> UIViewController {
        let viewModel = CabinetViewModel()
        let presenter = CabinetPresenterImpl(
            viewModel: viewModel,
            router: CabinetRouterImpl(navigationController: navigationController),
            stateStorage: stateStorage
        )
        let controller = UIHostingController(rootView: CabinetScreen(viewModel: viewModel, presenter: presenter))
        controller.title = L10n.Profile.Cabinet.title
        return controller
    }
}
