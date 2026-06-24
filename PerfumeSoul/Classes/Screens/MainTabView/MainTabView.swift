//
//  MainTabView.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    let todayScreen: NavigationControllerWrapper
    let discoverScreen: NavigationControllerWrapper
    let profileScreen: NavigationControllerWrapper
    let settingsScreen: NavigationControllerWrapper
    let searchPerfumeScreen: NavigationControllerWrapper
    
    init(
        todayScreen: NavigationControllerWrapper,
        discoverScreen: NavigationControllerWrapper,
        profileScreen: NavigationControllerWrapper,
        settingsScreen: NavigationControllerWrapper,
        searchPerfumeScreen: NavigationControllerWrapper
    ) {
        self.todayScreen = todayScreen
        self.discoverScreen = discoverScreen
        self.profileScreen = profileScreen
        self.settingsScreen = settingsScreen
        self.searchPerfumeScreen = searchPerfumeScreen
    }
    
    var body: some View {
        TabView {
            Tab(L10n.Screen.today, systemImage: "house.fill") {
                todayScreen
            }
            
            Tab(L10n.Screen.discover, systemImage: "sparkles") {
                discoverScreen
            }
            
            Tab(L10n.Screen.profile, systemImage: "person.crop.circle.fill") {
                profileScreen
            }
            
            Tab(L10n.Screen.settings, systemImage: "gearshape.fill") {
                settingsScreen
            }
            
            Tab(role: .search) {
                searchPerfumeScreen
            }
        }
    }
}

struct NavigationControllerWrapper: UIViewControllerRepresentable {
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
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        
    }
}
