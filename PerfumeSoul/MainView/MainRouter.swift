//
//  MainRouter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.03.2026.
//

import UIKit

protocol MainRouter {
    
}

final class MainRouterImpl {
   weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
}

extension MainRouterImpl: MainRouter {
    
}
