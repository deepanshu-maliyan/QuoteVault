//
//  Theme.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

// MARK: - App Colors
enum AppColor: String, CaseIterable, Codable {
    case blue = "blue"
    case red = "red"
    case green = "green"
    case orange = "orange"
    case purple = "purple"
    
    var color: Color {
        switch self {
        case .blue: return Color(hex: "4F46E5")
        case .red: return Color(hex: "EF4444")
        case .green: return Color(hex: "10B981")
        case .orange: return Color(hex: "F59E0B")
        case .purple: return Color(hex: "8B5CF6")
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .blue:
            return LinearGradient(
                colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .red:
            return LinearGradient(
                colors: [Color(hex: "EF4444"), Color(hex: "F97316")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orange:
            return LinearGradient(
                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .purple:
            return LinearGradient(
                colors: [Color(hex: "8B5CF6"), Color(hex: "EC4899")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Category Colors
enum CategoryColor {
    static func color(for categoryName: String) -> Color {
        switch categoryName.lowercased() {
        case "motivation": return Color(hex: "4F46E5")
        case "love": return Color(hex: "EC4899")
        case "success": return Color(hex: "F59E0B")
        case "wisdom": return Color(hex: "10B981")
        case "humor": return Color(hex: "8B5CF6")
        case "life": return Color(hex: "06B6D4")
        case "business": return Color(hex: "EF4444")
        case "creativity": return Color(hex: "F97316")
        case "growth": return Color(hex: "22C55E")
        default: return Color(hex: "6B7280")
        }
    }
}

// MARK: - Theme Mode
enum ThemeMode: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    case auto = "auto"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .auto: return nil
        }
    }
}

// MARK: - Typography
enum AppFont {
    static func regular(_ size: CGFloat) -> Font {
        return .system(size: size, weight: .regular, design: .default)
    }
    
    static func medium(_ size: CGFloat) -> Font {
        return .system(size: size, weight: .medium, design: .default)
    }
    
    static func semibold(_ size: CGFloat) -> Font {
        return .system(size: size, weight: .semibold, design: .default)
    }
    
    static func bold(_ size: CGFloat) -> Font {
        return .system(size: size, weight: .bold, design: .default)
    }
    
    static func quoteFont(_ size: CGFloat) -> Font {
        return .system(size: size, weight: .medium, design: .serif)
    }
}

// MARK: - Spacing
enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Background Colors
extension Color {
    static let appBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let primaryText = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
    static let tertiaryText = Color(UIColor.tertiaryLabel)
}
