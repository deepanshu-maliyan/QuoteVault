//
//  CollectionService.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - Collection Service
@MainActor
final class CollectionService {
    static let shared = CollectionService()
    
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    // MARK: - Fetch User Collections
    func fetchCollections(userId: UUID) async throws -> [CollectionWithCount] {
        let collections: [CollectionResponse] = try await supabase
            .from("collections")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        // Fetch quote counts for each collection
        var collectionsWithCount: [CollectionWithCount] = []
        for collection in collections {
            let quotes: [CollectionQuote] = try await supabase
                .from("collection_quotes")
                .select("id")
                .eq("collection_id", value: collection.id.uuidString)
                .execute()
                .value
            
            collectionsWithCount.append(
                CollectionWithCount(from: collection, quoteCount: quotes.count)
            )
        }
        
        return collectionsWithCount
    }
    
    // MARK: - Create Collection
    func createCollection(name: String, userId: UUID, coverImageUrl: String? = nil) async throws -> CollectionResponse {
        let request = CreateCollectionRequest(
            name: name,
            userId: userId,
            coverImageUrl: coverImageUrl
        )
        
        let collection: CollectionResponse = try await supabase
            .from("collections")
            .insert(request)
            .select()
            .single()
            .execute()
            .value
        
        return collection
    }
    
    // MARK: - Update Collection
    func updateCollection(id: UUID, name: String) async throws {
        try await supabase
            .from("collections")
            .update(["name": name, "updated_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Delete Collection
    func deleteCollection(id: UUID) async throws {
        try await supabase
            .from("collections")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // MARK: - Fetch Collection Quotes
    func fetchCollectionQuotes(collectionId: UUID) async throws -> [QuoteWithCategory] {
        let collectionQuotes: [CollectionQuote] = try await supabase
            .from("collection_quotes")
            .select()
            .eq("collection_id", value: collectionId.uuidString)
            .execute()
            .value
        
        let quoteIds = collectionQuotes.map { $0.quoteId.uuidString }
        
        guard !quoteIds.isEmpty else { return [] }
        
        let quotes: [QuoteWithCategory] = try await supabase
            .from("quotes")
            .select("*, categories(*)")
            .in("id", values: quoteIds)
            .execute()
            .value
        
        return quotes
    }
    
    // MARK: - Add Quote to Collection
    func addQuoteToCollection(quoteId: UUID, collectionId: UUID) async throws {
        let data: [String: String] = [
            "collection_id": collectionId.uuidString,
            "quote_id": quoteId.uuidString
        ]
        
        try await supabase
            .from("collection_quotes")
            .insert(data)
            .execute()
    }
    
    // MARK: - Remove Quote from Collection
    func removeQuoteFromCollection(quoteId: UUID, collectionId: UUID) async throws {
        try await supabase
            .from("collection_quotes")
            .delete()
            .eq("collection_id", value: collectionId.uuidString)
            .eq("quote_id", value: quoteId.uuidString)
            .execute()
    }
    
    // MARK: - Check if Quote is in Collection
    func isQuoteInCollection(quoteId: UUID, collectionId: UUID) async throws -> Bool {
        let results: [CollectionQuote] = try await supabase
            .from("collection_quotes")
            .select("id")
            .eq("collection_id", value: collectionId.uuidString)
            .eq("quote_id", value: quoteId.uuidString)
            .execute()
            .value
        
        return !results.isEmpty
    }
}
