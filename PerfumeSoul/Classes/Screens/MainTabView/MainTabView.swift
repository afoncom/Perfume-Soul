//
//  MainTabView.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.06.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

private enum MainTab: Hashable {
    case today
    case discover
    case profile
    case settings
    case search
}

struct MainTabView: View {
    let todayScreen: NavigationControllerContainer
    let discoverScreen: NavigationControllerContainer
    let profileScreen: NavigationControllerContainer
    let settingsScreen: NavigationControllerContainer
    let searchPerfumeScreen: NavigationControllerContainer
    
    @State private var selectedTab: MainTab = .today
    @State private var previousTab: MainTab = .today
    @State private var isShowingSearchScreen = false
    
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
        TabView(selection: $selectedTab) {
            Tab(L10n.Screen.today, systemImage: "house.fill", value: .today) {
                todayScreen
            }
            
            Tab(L10n.Screen.discover, systemImage: "sparkles", value: .discover) {
                discoverScreen
            }
            
            Tab(L10n.Screen.profile, systemImage: "person.crop.circle.fill", value: .profile) {
                profileScreen
            }
            
            Tab(L10n.Screen.settings, systemImage: "gearshape.fill", value: .settings) {
                settingsScreen
            }
            
            Tab(value: .search, role: .search) {
                Color.clear
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            guard newValue == .search else {
                previousTab = newValue
                return
            }

            selectedTab = previousTab
            isShowingSearchScreen = true
        }
        .sheet(isPresented: $isShowingSearchScreen) {
            searchPerfumeScreen
        }
    }
}
