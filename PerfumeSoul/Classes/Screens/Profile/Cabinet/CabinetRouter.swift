//
//  CabinetRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import UIKit

protocol CabinetRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class CabinetRouterImpl {
    private weak var navigationController: UINavigationController?
    private let imageLoader: PerfumeImageLoader
    private let requestManager: RequestManager

    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager,
        imageLoader: PerfumeImageLoader
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
        self.imageLoader = imageLoader
    }
}

extension CabinetRouterImpl: CabinetRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(
                perfume: perfume,
                requestManager: requestManager,
                imageLoader: imageLoader
            ),
            animated: true
        )
    }
}
