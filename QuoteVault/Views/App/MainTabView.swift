//
//  MainTabView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var navigation = NavigationManager.shared
    @StateObject private var stateManager = AppStateManager.shared
    
    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: navigation.selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            DiscoverView()
                .tabItem {
                    Image(systemName: navigation.selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    Text("Explore")
                }
                .tag(1)
            
            SavedView()
                .tabItem {
                    Image(systemName: navigation.selectedTab == 2 ? "bookmark.fill" : "bookmark")
                    Text("Saved")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: navigation.selectedTab == 3 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(stateManager.accentColor.color)
    }
}

#Preview {
    MainTabView()
}
