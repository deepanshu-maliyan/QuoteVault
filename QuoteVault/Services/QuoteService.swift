//
//  QuoteService.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - Quote Service
@MainActor
final class QuoteService {
    static let shared = QuoteService()
    
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    // MARK: - Fetch Quote of the Day
    func fetchQuoteOfDay() async throws -> QuoteWithCategory? {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)
        
        // First try to get today's quote
        let quotes: [QuoteWithCategory] = try await supabase
            .from("quotes")
            .select("*, categories(*)")
            .eq("quote_of_day_date", value: todayString)
            .limit(1)
            .execute()
            .value
        
        if let quote = quotes.first {
            return quote
        }
        
        // If no quote for today, get a random one and set it as quote of the day
        let randomQuotes: [QuoteWithCategory] = try await supabase
            .from("quotes")
            .select("*, categories(*)")
            .is("quote_of_day_date", value: nil)
            .limit(1)
            .execute()
            .value
        
        if let quote = randomQuotes.first {
            // Update the quote to be today's quote
            struct QuoteOfDayUpdate: Codable {
                let quote_of_day_date: String
                let is_quote_of_day: Bool
            }
            
            try await supabase
                .from("quotes")
                .update(QuoteOfDayUpdate(quote_of_day_date: todayString, is_quote_of_day: true))
                .eq("id", value: quote.id.uuidString)
                .execute()
            
            return quote
        }
        
        // Fallback: get any quote
        let fallbackQuotes: [QuoteWithCategory] = try await supabase
            .from("quotes")
            .select("*, categories(*)")
            .limit(1)
            .execute()
            .value
        
        return fallbackQuotes.first
    }
    
    // MARK: - Fetch All Quotes (Paginated)
    func fetchQuotes(
        categoryId: UUID? = nil,
        searchQuery: String? = nil,
        page: Int = 0,
        pageSize: Int = 20
    ) async throws -> [QuoteWithCategory] {
        var query = supabase
            .from("quotes")
            .select("*, categories(*)")
        
        if let categoryId = categoryId {
            query = query.eq("category_id", value: categoryId.uuidString)
        }
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            query = query.or("text.ilike.%\(searchQuery)%,author.ilike.%\(searchQuery)%")
        }
        
        let quotes: [QuoteWithCategory] = try await query
            .order("created_at", ascending: false)
            .range(from: page * pageSize, to: (page + 1) * pageSize - 1)
            .execute()
            .value
        
        return quotes
    }
    
    // MARK: - Fetch Quote by ID
    func fetchQuote(id: UUID) async throws -> QuoteWithCategory {
        let quote: QuoteWithCategory = try await supabase
            .from("quotes")
            .select("*, categories(*)")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
        
        return quote
    }
    
    // MARK: - Fetch Recommended Quotes
    func fetchRecommendedQuotes(limit: Int = 10) async throws -> [QuoteWithCategory] {
        let quotes: [QuoteWithCategory] = try await supabase
            .from("quotes")
            .select("*, categories(*)")
            .order("likes_count", ascending: false)
            .limit(limit)
            .execute()
            .value
        
        return quotes
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() async throws -> [CategoryResponse] {
        let categories: [CategoryResponse] = try await supabase
            .from("categories")
            .select()
            .order("name", ascending: true)
            .execute()
            .value
        
        return categories
    }
    
    // MARK: - Increment Like Count
    func incrementLikeCount(quoteId: UUID) async throws {
        // Use RPC for atomic increment
        try await supabase.rpc(
            "increment_likes",
            params: ["quote_id": quoteId.uuidString]
        ).execute()
    }
}

// MARK: - API Ninjas Quote Service
@MainActor
final class APINinjasQuoteService {
    static let shared = APINinjasQuoteService()
    
    private init() {}
    
    func fetchRandomQuote(category: String? = nil) async throws -> APINinjasQuote {
        var urlString = "\(Constants.APINinjas.baseURL)/quotes"
        if let category = category {
            urlString += "?category=\(category)"
        }
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.setValue(Constants.APINinjas.apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Failed to fetch quote")
        }
        
        let quotes = try JSONDecoder().decode([APINinjasQuote].self, from: data)
        
        guard let quote = quotes.first else {
            throw NetworkError.notFound
        }
        
        return quote
    }
}
