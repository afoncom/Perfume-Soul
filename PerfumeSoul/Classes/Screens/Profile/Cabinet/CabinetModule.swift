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
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) -> UIViewController {
        let viewModel = CabinetViewModel()
        let presenter = CabinetPresenterImpl(
            viewModel: viewModel,
            router: CabinetRouterImpl(
                navigationController: navigationController,
                requestManager: requestManager,
                imageLoader: imageLoader
            ),
            collectionService: PerfumeCollectionServiceImpl(
                storage: PerfumeCollectionStorageImpl(userDefaults: .standard)
            )
        )
        let controller = UIHostingController(rootView: CabinetScreen(viewModel: viewModel, presenter: presenter, imageLoader: imageLoader))
        controller.title = L10n.Profile.Cabinet.title
        return controller
    }
}
