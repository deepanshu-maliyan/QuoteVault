//
//  Category.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import SwiftUI

// MARK: - Category Model (Supabase Response)
struct CategoryResponse: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String?
    let color: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, color
        case createdAt = "created_at"
    }
    
    var displayColor: Color {
        if let colorHex = color {
            return Color(hex: colorHex)
        }
        return CategoryColor.color(for: name)
    }
    
    var systemIcon: String {
        icon ?? "quote.bubble.fill"
    }
}

// MARK: - Category Filter Option
struct CategoryFilter: Identifiable, Hashable {
    let id: UUID?
    let name: String
    let icon: String
    let color: Color
    
    static let all = CategoryFilter(
        id: nil,
        name: "All",
        icon: "square.grid.2x2.fill",
        color: Color(hex: "6B7280")
    )
    
    init(id: UUID?, name: String, icon: String, color: Color) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
    }
    
    init(from response: CategoryResponse) {
        self.id = response.id
        self.name = response.name
        self.icon = response.systemIcon
        self.color = response.displayColor
    }
}
