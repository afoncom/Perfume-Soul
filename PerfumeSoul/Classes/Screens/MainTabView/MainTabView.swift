//
//  MainTabView.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    let todayScreen: NavigationControllerContainer
    let discoverScreen: NavigationControllerContainer
    let profileScreen: NavigationControllerContainer
    let settingsScreen: NavigationControllerContainer
    let searchPerfumeScreen: NavigationControllerContainer
    
    init(
        todayScreen: NavigationControllerContainer,
        discoverScreen: NavigationControllerContainer,
        profileScreen: NavigationControllerContainer,
        settingsScreen: NavigationControllerContainer,
        searchPerfumeScreen: NavigationControllerContainer
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
