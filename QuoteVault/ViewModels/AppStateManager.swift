//
//  AppStateManager.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    @Published var themeMode: ThemeMode = .auto
    @Published var accentColor: AppColor = .blue
    @Published var fontSize: CGFloat = 16
    
    static let shared = AppStateManager()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Listen to profile changes
        AuthService.shared.$currentProfile
            .compactMap { $0 }
            .sink { [weak self] profile in
                self?.updateFromProfile(profile)
            }
            .store(in: &cancellables)
    }
    
    func updateFromProfile(_ profile: UserProfile) {
        self.themeMode = profile.themeMode
        self.accentColor = profile.appColor
        self.fontSize = CGFloat(profile.fontSize)
    }
}
