//
//  Quote.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import SwiftData

// MARK: - Quote Model (Supabase Response)
struct QuoteResponse: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let author: String
    let authorImageUrl: String?
    let categoryId: UUID?
    let likesCount: Int
    let commentsCount: Int
    let isQuoteOfDay: Bool
    let quoteOfDayDate: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, text, author
        case authorImageUrl = "author_image_url"
        case categoryId = "category_id"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isQuoteOfDay = "is_quote_of_day"
        case quoteOfDayDate = "quote_of_day_date"
        case createdAt = "created_at"
    }
}

// MARK: - Quote with Category (Joined Response)
struct QuoteWithCategory: Codable, Identifiable, Hashable {
    let id: UUID
    let text: String
    let author: String
    let authorImageUrl: String?
    let categoryId: UUID?
    let likesCount: Int
    let commentsCount: Int
    let isQuoteOfDay: Bool
    let quoteOfDayDate: String?
    let createdAt: String
    let categories: CategoryResponse?
    
    enum CodingKeys: String, CodingKey {
        case id, text, author, categories
        case authorImageUrl = "author_image_url"
        case categoryId = "category_id"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isQuoteOfDay = "is_quote_of_day"
        case quoteOfDayDate = "quote_of_day_date"
        case createdAt = "created_at"
    }
    
    var categoryName: String {
        categories?.name ?? "General"
    }
}

// MARK: - SwiftData Model for Offline Caching
@Model
final class CachedQuote {
    @Attribute(.unique) var id: UUID
    var text: String
    var author: String
    var authorImageUrl: String?
    var categoryId: UUID?
    var categoryName: String
    var likesCount: Int
    var commentsCount: Int
    var isQuoteOfDay: Bool
    var quoteOfDayDate: Date?
    var isFavorite: Bool
    var cachedAt: Date
    
    init(
        id: UUID,
        text: String,
        author: String,
        authorImageUrl: String? = nil,
        categoryId: UUID? = nil,
        categoryName: String = "General",
        likesCount: Int = 0,
        commentsCount: Int = 0,
        isQuoteOfDay: Bool = false,
        quoteOfDayDate: Date? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.authorImageUrl = authorImageUrl
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.isQuoteOfDay = isQuoteOfDay
        self.quoteOfDayDate = quoteOfDayDate
        self.isFavorite = isFavorite
        self.cachedAt = Date()
    }
    
    convenience init(from response: QuoteWithCategory) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let qotdDate = response.quoteOfDayDate.flatMap { dateFormatter.date(from: $0) }
        
        self.init(
            id: response.id,
            text: response.text,
            author: response.author,
            authorImageUrl: response.authorImageUrl,
            categoryId: response.categoryId,
            categoryName: response.categoryName,
            likesCount: response.likesCount,
            commentsCount: response.commentsCount,
            isQuoteOfDay: response.isQuoteOfDay,
            quoteOfDayDate: qotdDate
        )
    }
}

// MARK: - API Ninjas Quote Response
struct APINinjasQuote: Codable {
    let quote: String
    let author: String
    let category: String
}
