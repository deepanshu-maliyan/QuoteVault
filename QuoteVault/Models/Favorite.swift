//
//  Favorite.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - Favorite Model (Supabase Response)
struct FavoriteResponse: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let quoteId: UUID
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case quoteId = "quote_id"
        case createdAt = "created_at"
    }
}

// MARK: - Favorite with Quote
struct FavoriteWithQuote: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let quoteId: UUID
    let createdAt: String
    let quotes: QuoteWithCategory
    
    enum CodingKeys: String, CodingKey {
        case id, quotes
        case userId = "user_id"
        case quoteId = "quote_id"
        case createdAt = "created_at"
    }
}

// MARK: - Create Favorite Request
struct CreateFavoriteRequest: Codable {
    let userId: UUID
    let quoteId: UUID
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case quoteId = "quote_id"
    }
}
