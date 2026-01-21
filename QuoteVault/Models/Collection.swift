//
//  Collection.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import SwiftData

// MARK: - Collection Model (Supabase Response)
struct CollectionResponse: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let name: String
    let coverImageUrl: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
        case coverImageUrl = "cover_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Collection with Quote Count
struct CollectionWithCount: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let name: String
    let coverImageUrl: String?
    let createdAt: String
    let updatedAt: String
    var quoteCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
        case coverImageUrl = "cover_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case quoteCount = "quote_count"
    }
    
    init(from response: CollectionResponse, quoteCount: Int = 0) {
        self.id = response.id
        self.userId = response.userId
        self.name = response.name
        self.coverImageUrl = response.coverImageUrl
        self.createdAt = response.createdAt
        self.updatedAt = response.updatedAt
        self.quoteCount = quoteCount
    }
}

// MARK: - Collection Quote Junction
struct CollectionQuote: Codable, Identifiable {
    let id: UUID
    let collectionId: UUID
    let quoteId: UUID
    let addedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case collectionId = "collection_id"
        case quoteId = "quote_id"
        case addedAt = "added_at"
    }
}

// MARK: - Create Collection Request
struct CreateCollectionRequest: Codable {
    let name: String
    let userId: UUID
    let coverImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case userId = "user_id"
        case coverImageUrl = "cover_image_url"
    }
}

// MARK: - SwiftData Model for Offline Caching
@Model
final class CachedCollection {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var name: String
    var coverImageUrl: String?
    var quoteCount: Int
    var cachedAt: Date
    
    init(
        id: UUID,
        userId: UUID,
        name: String,
        coverImageUrl: String? = nil,
        quoteCount: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.coverImageUrl = coverImageUrl
        self.quoteCount = quoteCount
        self.cachedAt = Date()
    }
    
    convenience init(from response: CollectionWithCount) {
        self.init(
            id: response.id,
            userId: response.userId,
            name: response.name,
            coverImageUrl: response.coverImageUrl,
            quoteCount: response.quoteCount
        )
    }
}
