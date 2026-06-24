//
//  NavigationControllerContainer.swift
//  PerfumeSoul
//
//  Created by afon.com on 24.06.2026.
//

import SwiftUI

struct NavigationControllerContainer: UIViewControllerRepresentable {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    init(viewController: UIViewController) {
        if let navigationController = viewController as? UINavigationController {
            self.navigationController = navigationController
        } else {
            self.navigationController = UINavigationController(rootViewController: viewController)
        }
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        navigationController
    }
    
    func updateUIViewController(_ navigationConroller: UINavigationController, context: Context) {
        
    }
}
