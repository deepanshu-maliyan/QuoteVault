//
//  Constants.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

enum Constants {
    // MARK: - Supabase Configuration
    enum Supabase {
        static let url = "https://dhhxowjovplmkhyxxytr.supabase.co"
        static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRoaHhvd2pvdnBsbWtoeXh4eXRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5OTU0ODUsImV4cCI6MjA4NDU3MTQ4NX0.tUHKg9xNRV2xV9aEN9EVJP6qJjnYV9VDT0RLZAA7G-0"
    }
    
    // MARK: - API Ninjas Configuration
    enum APINinjas {
        static let baseURL = "https://api.api-ninjas.com/v2"
        static let apiKey = "uRbXVNLXDY1VihQ2XS0O9BiAiVxEncyLxE23Hy2K"
    }
    
    // MARK: - App Settings
    enum App {
        static let name = "QuoteVault"
        static let tagline = "Discover, save, and revisit the words that inspire you."
    }
    
    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let accentColor = "accentColor"
        static let fontSize = "fontSize"
        static let theme = "theme"
        static let notificationEnabled = "notificationEnabled"
        static let notificationTime = "notificationTime"
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }
    
    // MARK: - Notification Identifiers
    enum Notifications {
        static let dailyQuoteIdentifier = "dailyQuoteNotification"
    }
}
