//
//  PersonalPerfumeModule.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

final class PersonalPerfumeModule {
    static func build(
        profileCalculation: ProfileCalculation?,
        requestManager: RequestManager,
        onFinish: (() -> Void)? = nil
    ) -> UIViewController {
        let viewModel = PersonalPerfumeViewModel()
        let router = PersonalPerfumeRouterImpl(onFinish: onFinish)
        let service = PersonalPerfumeServiceImpl(requestManager: requestManager)
        let presenter = PersonalPerfumePresenterImpl(
            viewModel: viewModel,
            router: router,
            service: service,
            profileCalculation: profileCalculation,
            shouldShowContinueButton: onFinish != nil
        )
        
        let view = PersonalPerfumeScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        hostingController.title = L10n.PersonalPerfume.navigationTitle
        hostingController.navigationItem.largeTitleDisplayMode = .never
        hostingController.hidesBottomBarWhenPushed = true

        return hostingController
    }
}
