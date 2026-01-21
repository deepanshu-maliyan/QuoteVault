//
//  SettingsViewModel.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import SwiftUI

// MARK: - Settings View Model
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var displayName: String = ""
    @Published var selectedTheme: ThemeMode = .auto
    @Published var selectedAccentColor: AppColor = .blue
    @Published var fontSize: CGFloat = 16
    @Published var notificationEnabled: Bool = true
    @Published var notificationTime: Date = Date()
    @Published var isLoading = false
    @Published var error: String?
    @Published var showSaveSuccess = false
    
    private let authService = AuthService.shared
    private let notificationService = NotificationService.shared
    private let stateManager = AppStateManager.shared
    private let navigation = NavigationManager.shared
    
    // MARK: - Load Settings
    func loadSettings() {
        guard let profile = authService.currentProfile else { return }
        
        displayName = profile.displayName ?? ""
        selectedTheme = profile.themeMode
        selectedAccentColor = profile.appColor
        fontSize = CGFloat(profile.fontSize)
        notificationEnabled = profile.notificationEnabled
        notificationTime = profile.notificationTimeDate
    }
    
    // MARK: - Save Settings
    func saveSettings() async {
        isLoading = true
        error = nil
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let timeString = timeFormatter.string(from: notificationTime)
        
        let update = ProfileUpdateRequest(
            displayName: displayName.isEmpty ? nil : displayName,
            accentColor: selectedAccentColor.rawValue,
            fontSize: Int(fontSize),
            theme: selectedTheme.rawValue,
            notificationEnabled: notificationEnabled,
            notificationTime: timeString
        )
        
        do {
            try await authService.updateProfile(update)
            
            // Update global state immediately
            stateManager.themeMode = selectedTheme
            stateManager.accentColor = selectedAccentColor
            stateManager.fontSize = fontSize
            
            // Update notification schedule
            if notificationEnabled {
                if let quote = try? await QuoteService.shared.fetchQuoteOfDay() {
                    await notificationService.scheduleDailyQuoteNotification(
                        at: notificationTime,
                        quote: quote.text,
                        author: quote.author
                    )
                }
            } else {
                notificationService.cancelDailyQuoteNotification()
            }
            
            showSaveSuccess = true
            
            // Hide success message after 2 seconds
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                showSaveSuccess = false
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        try await authService.signOut()
    }
    
    // MARK: - Request Notification Permission
    func requestNotificationPermission() async -> Bool {
        return await notificationService.requestPermission()
    }
}
