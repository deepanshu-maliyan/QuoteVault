//
//  FavoritesViewModel.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - Favorites View Model
@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [FavoriteWithQuote] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let favoriteService = FavoriteService.shared
    
    // MARK: - Load Favorites
    func loadFavorites() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            self.favorites = try await favoriteService.fetchFavorites(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadFavorites()
    }
    
    // MARK: - Remove Favorite
    func removeFavorite(quoteId: UUID) async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        do {
            try await favoriteService.removeFavorite(quoteId: quoteId, userId: userId)
            favorites.removeAll { $0.quoteId == quoteId }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
