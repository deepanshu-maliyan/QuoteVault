//
//  NavigationManager.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

@MainActor
class NavigationManager: ObservableObject {
    @Published var selectedTab: Int = 0
    
    static let shared = NavigationManager()
    private init() {}
    
    func switchToTab(_ tab: Int) {
        selectedTab = tab
    }
}
