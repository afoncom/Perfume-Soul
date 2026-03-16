//
//  PerfumeRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit

protocol PerfumeRouter {
    
}

final class PerfumeRouterImpl {
    weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
}

extension PerfumeRouterImpl: PerfumeRouter {
    
}
