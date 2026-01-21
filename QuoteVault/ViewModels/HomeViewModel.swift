//
//  HomeViewModel.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import SwiftUI

// MARK: - Home View Model
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var quoteOfDay: QuoteWithCategory?
    @Published var categories: [CategoryResponse] = []
    @Published var recommendedQuotes: [QuoteWithCategory] = []
    @Published var favoriteQuoteIds: Set<UUID> = []
    @Published var selectedCategoryId: UUID? = nil
    @Published var isLoading = false
    @Published var error: String?
    
    private let quoteService = QuoteService.shared
    private let favoriteService = FavoriteService.shared
    
    // MARK: - Load Home Data
    func loadHomeData() async {
        isLoading = true
        error = nil
        
        do {
            async let qotd = quoteService.fetchQuoteOfDay()
            async let cats = quoteService.fetchCategories()
            async let recommended = quoteService.fetchRecommendedQuotes(limit: 10)
            
            let (quoteOfDayResult, categoriesResult, recommendedResult) = try await (qotd, cats, recommended)
            
            self.quoteOfDay = quoteOfDayResult
            self.categories = categoriesResult
            self.recommendedQuotes = recommendedResult
            
            // Load favorite status if user is logged in
            if let userId = AuthService.shared.currentUser?.id {
                self.favoriteQuoteIds = try await favoriteService.getFavoriteQuoteIds(userId: userId)
            }
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Select Category
    func selectCategory(id: UUID?) async {
        selectedCategoryId = id
        isLoading = true
        do {
            self.recommendedQuotes = try await quoteService.fetchQuotes(
                categoryId: id,
                page: 0,
                pageSize: 10
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadHomeData()
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(quoteId: UUID) async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        do {
            let isFavorite = try await favoriteService.toggleFavorite(quoteId: quoteId, userId: userId)
            
            if isFavorite {
                favoriteQuoteIds.insert(quoteId)
            } else {
                favoriteQuoteIds.remove(quoteId)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Check if Favorited
    func isFavorited(_ quoteId: UUID) -> Bool {
        favoriteQuoteIds.contains(quoteId)
    }
    
    // MARK: - Get Greeting
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<22:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    // MARK: - Get User Display Name
    func getUserDisplayName() -> String {
        AuthService.shared.currentProfile?.displayName ?? "User"
    }
}
