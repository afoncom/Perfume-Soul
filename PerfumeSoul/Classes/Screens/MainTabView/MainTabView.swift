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
    var historyNotificationID: UUID?
    
    @State private var selectedTab: MainTab = .today
    
    var body: some View {
        if #available(iOS 26.0, *) {
            makeTabView()
                .tabBarMinimizeBehavior(.onScrollDown)
        } else {
            makeTabView()
        }
    }
}

extension MainTabView {
    private func handleHistoryNotification() {
        selectedTab = .today
        todayScreen.navigationController.popToRootViewController(animated: false)
    }
}

extension MainTabView {
    private func makeTabView() -> some View {
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
                searchPerfumeScreen
            }
        }
        .onChange(of: historyNotificationID) { _, _ in
            handleHistoryNotification()
        }
    }
}
