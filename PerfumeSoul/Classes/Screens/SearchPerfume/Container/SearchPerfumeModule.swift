//
//  SearchPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class SearchPerfumeModule {
    static func build(requestManager: RequestManager) -> SearchPerfumeScreen {
        let viewModel = SearchPerfumeViewModel()
        let searchPerfumeService = SearchPerfumeServiceImpl(requestManager: requestManager)
        let navigationController = UINavigationController()
        let router = SearchPerfumeRouterImpl(navigationController: navigationController)
        let presenter = SearchPerfumePresenterImpl(
            viewModel: viewModel,
            router: router,
            searchPerfumeService: searchPerfumeService
        )

        return SearchPerfumeScreen(viewModel: viewModel, presenter: presenter)
    }
}
