//
//  RootView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var stateManager = AppStateManager.shared
    @AppStorage(Constants.UserDefaultsKeys.hasSeenOnboarding) private var hasSeenOnboarding = false
    
    var body: some View {
        Group {
            if authService.isLoading && authService.currentUser == nil {
                // Loading state while checking session
                LoadingView(message: "Loading...")
            } else if authService.isAuthenticated {
                // User is logged in
                MainTabView()
            } else {
                // User needs to authenticate
                WelcomeView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
        .preferredColorScheme(stateManager.themeMode.colorScheme)
        .environment(\.accentColor, stateManager.accentColor.color)
    }
}

#Preview {
    RootView()
}
