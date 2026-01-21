//
//  DiscoverViewModel.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import Combine

// MARK: - Discover View Model
@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var quotes: [QuoteWithCategory] = []
    @Published var categories: [CategoryFilter] = []
    @Published var selectedCategory: CategoryFilter = .all
    @Published var searchQuery = ""
    @Published var favoriteQuoteIds: Set<UUID> = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    @Published var error: String?
    
    private var currentPage = 0
    private let pageSize = 20
    private let quoteService = QuoteService.shared
    private let favoriteService = FavoriteService.shared
    
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Load Initial Data
    func loadInitialData() async {
        isLoading = true
        error = nil
        currentPage = 0
        hasMorePages = true
        
        do {
            // Load categories
            let categoryResponses = try await quoteService.fetchCategories()
            self.categories = [.all] + categoryResponses.map { CategoryFilter(from: $0) }
            
            // Load quotes
            await loadQuotes(reset: true)
            
            // Load favorite status
            if let userId = AuthService.shared.currentUser?.id {
                self.favoriteQuoteIds = try await favoriteService.getFavoriteQuoteIds(userId: userId)
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Load Quotes
    func loadQuotes(reset: Bool = false) async {
        if reset {
            currentPage = 0
            hasMorePages = true
        }
        
        guard hasMorePages else { return }
        
        do {
            let newQuotes = try await quoteService.fetchQuotes(
                categoryId: selectedCategory.id,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                page: currentPage,
                pageSize: pageSize
            )
            
            if reset {
                self.quotes = newQuotes
            } else {
                self.quotes.append(contentsOf: newQuotes)
            }
            
            hasMorePages = newQuotes.count == pageSize
            currentPage += 1
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Load More Quotes
    func loadMoreIfNeeded(currentQuote: QuoteWithCategory) async {
        guard let lastQuote = quotes.last,
              lastQuote.id == currentQuote.id,
              !isLoadingMore,
              hasMorePages else { return }
        
        isLoadingMore = true
        await loadQuotes()
        isLoadingMore = false
    }
    
    // MARK: - Search
    func search() {
        searchTask?.cancel()
        
        searchTask = Task {
            // Debounce
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            guard !Task.isCancelled else { return }
            
            isLoading = true
            await loadQuotes(reset: true)
            isLoading = false
        }
    }
    
    // MARK: - Select Category
    func selectCategory(_ category: CategoryFilter) async {
        selectedCategory = category
        isLoading = true
        self.quotes = [] // Clear for immediate feedback
        await loadQuotes(reset: true)
        isLoading = false
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadQuotes(reset: true)
        
        if let userId = AuthService.shared.currentUser?.id {
            do {
                self.favoriteQuoteIds = try await favoriteService.getFavoriteQuoteIds(userId: userId)
            } catch {
                print("Error loading favorites: \(error)")
            }
        }
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
}
