import UIKit

protocol RecommendedPerfumeRouter {
    @MainActor
    func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class RecommendedPerfumeRouterImpl {
    private weak var navigationController: UINavigationController?
    private let requestManager: RequestManager

    init(
        navigationController: UINavigationController?,
        requestManager: RequestManager
    ) {
        self.navigationController = navigationController
        self.requestManager = requestManager
    }
}

extension RecommendedPerfumeRouterImpl: RecommendedPerfumeRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(
                perfume: perfume,
                requestManager: requestManager
            ),
            animated: true
        )
    }
}
