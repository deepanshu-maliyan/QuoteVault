//
//  UserProfile.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - User Profile Model (Supabase Response)
struct UserProfile: Codable, Identifiable {
    let id: UUID
    var displayName: String?
    var avatarUrl: String?
    var accentColor: String
    var fontSize: Int
    var theme: String
    var notificationEnabled: Bool
    var notificationTime: String
    let createdAt: String
    var updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case accentColor = "accent_color"
        case fontSize = "font_size"
        case theme
        case notificationEnabled = "notification_enabled"
        case notificationTime = "notification_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var appColor: AppColor {
        AppColor(rawValue: accentColor) ?? .blue
    }
    
    var themeMode: ThemeMode {
        ThemeMode(rawValue: theme) ?? .auto
    }
    
    var notificationTimeDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.date(from: notificationTime) ?? Date()
    }
}

// MARK: - Profile Update Request
struct ProfileUpdateRequest: Codable {
    var displayName: String?
    var avatarUrl: String?
    var accentColor: String?
    var fontSize: Int?
    var theme: String?
    var notificationEnabled: Bool?
    var notificationTime: String?
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case accentColor = "accent_color"
        case fontSize = "font_size"
        case theme
        case notificationEnabled = "notification_enabled"
        case notificationTime = "notification_time"
    }
}
