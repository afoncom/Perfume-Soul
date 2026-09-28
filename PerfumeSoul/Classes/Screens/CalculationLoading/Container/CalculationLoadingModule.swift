//
//  CalculationLoadingModule.swift
//  PerfumeSoul
//

import SwiftUI
import CoreData

final class CalculationLoadingModule {
    @MainActor
    static func build(
        container: NSPersistentContainer,
        requestManager: RequestManager,
        navigationController: UINavigationController?,
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let viewModel = CalculationLoadingViewModel()
        let router = CalculationLoadingRouterImpl(
            navigationController: navigationController,
            container: container,
            requestManager: requestManager,
            onFinish: onFinish
        )
        
        let presenter = CalculationLoadingPresenterImpl(
            viewModel: viewModel,
            router: router,
            profileService: ProfileServiceImpl(container: container),
            profileCalculationService: ProfileCalculationServiceImpl(requestManager: requestManager)
        )
        
        let view = CalculationLoadingScreen(viewModel: viewModel, presenter: presenter)
        let hostingController = UIHostingController(rootView: view)
        hostingController.hidesBottomBarWhenPushed = true

        return hostingController
    }
}
