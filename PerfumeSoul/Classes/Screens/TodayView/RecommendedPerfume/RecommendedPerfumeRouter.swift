import UIKit

protocol RecommendedPerfumeRouter {
    @MainActor
    func showPerfumeDetailsScreen(perfume: SearchPerfumeItem)
}

final class RecommendedPerfumeRouterImpl {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension RecommendedPerfumeRouterImpl: RecommendedPerfumeRouter {
    @MainActor func showPerfumeDetailsScreen(perfume: SearchPerfumeItem) {
        navigationController?.pushViewController(
            PerfumeDetailsModule.build(perfume: perfume),
            animated: true
        )
    }
}
