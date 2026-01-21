//
//  FavoriteService.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - Favorite Service
@MainActor
final class FavoriteService {
    static let shared = FavoriteService()
    
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    // MARK: - Fetch User Favorites
    func fetchFavorites(userId: UUID) async throws -> [FavoriteWithQuote] {
        let favorites: [FavoriteWithQuote] = try await supabase
            .from("favorites")
            .select("*, quotes(*, categories(*))")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return favorites
    }
    
    // MARK: - Check if Quote is Favorited
    func isFavorited(quoteId: UUID, userId: UUID) async throws -> Bool {
        let favorites: [FavoriteResponse] = try await supabase
            .from("favorites")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .eq("quote_id", value: quoteId.uuidString)
            .execute()
            .value
        
        return !favorites.isEmpty
    }
    
    // MARK: - Get Favorite IDs for User
    func getFavoriteQuoteIds(userId: UUID) async throws -> Set<UUID> {
        let favorites: [FavoriteResponse] = try await supabase
            .from("favorites")
            .select("quote_id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        
        return Set(favorites.map { $0.quoteId })
    }
    
    // MARK: - Add Favorite
    func addFavorite(quoteId: UUID, userId: UUID) async throws {
        let request = CreateFavoriteRequest(userId: userId, quoteId: quoteId)
        
        try await supabase
            .from("favorites")
            .insert(request)
            .execute()
    }
    
    // MARK: - Remove Favorite
    func removeFavorite(quoteId: UUID, userId: UUID) async throws {
        try await supabase
            .from("favorites")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("quote_id", value: quoteId.uuidString)
            .execute()
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(quoteId: UUID, userId: UUID) async throws -> Bool {
        let isFav = try await isFavorited(quoteId: quoteId, userId: userId)
        
        if isFav {
            try await removeFavorite(quoteId: quoteId, userId: userId)
            return false
        } else {
            try await addFavorite(quoteId: quoteId, userId: userId)
            return true
        }
    }
}
