//
//  CollectionsViewModel.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation

// MARK: - Collections View Model
@MainActor
final class CollectionsViewModel: ObservableObject {
    @Published var collections: [CollectionWithCount] = []
    @Published var selectedCollection: CollectionWithCount?
    @Published var collectionQuotes: [QuoteWithCategory] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let collectionService = CollectionService.shared
    
    // MARK: - Load Collections
    func loadCollections() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            self.collections = try await collectionService.fetchCollections(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Create Collection
    func createCollection(name: String) async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        do {
            let collection = try await collectionService.createCollection(name: name, userId: userId)
            let newCollection = CollectionWithCount(from: collection, quoteCount: 0)
            collections.insert(newCollection, at: 0)
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Update Collection
    func updateCollection(id: UUID, name: String) async {
        do {
            try await collectionService.updateCollection(id: id, name: name)
            
            if let index = collections.firstIndex(where: { $0.id == id }) {
                var updated = collections[index]
                updated = CollectionWithCount(
                    id: updated.id,
                    userId: updated.userId,
                    name: name,
                    coverImageUrl: updated.coverImageUrl,
                    createdAt: updated.createdAt,
                    updatedAt: ISO8601DateFormatter().string(from: Date()),
                    quoteCount: updated.quoteCount
                )
                collections[index] = updated
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Delete Collection
    func deleteCollection(id: UUID) async {
        do {
            try await collectionService.deleteCollection(id: id)
            collections.removeAll { $0.id == id }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Load Collection Quotes
    func loadCollectionQuotes(collectionId: UUID) async {
        isLoading = true
        
        do {
            self.collectionQuotes = try await collectionService.fetchCollectionQuotes(collectionId: collectionId)
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Add Quote to Collection
    func addQuoteToCollection(quoteId: UUID, collectionId: UUID) async {
        do {
            try await collectionService.addQuoteToCollection(quoteId: quoteId, collectionId: collectionId)
            
            // Update quote count
            if let index = collections.firstIndex(where: { $0.id == collectionId }) {
                var updated = collections[index]
                updated.quoteCount += 1
                collections[index] = updated
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Remove Quote from Collection
    func removeQuoteFromCollection(quoteId: UUID, collectionId: UUID) async {
        do {
            try await collectionService.removeQuoteFromCollection(quoteId: quoteId, collectionId: collectionId)
            
            // Update quote count
            if let index = collections.firstIndex(where: { $0.id == collectionId }) {
                var updated = collections[index]
                updated.quoteCount = max(0, updated.quoteCount - 1)
                collections[index] = updated
            }
            
            // Remove from current view if viewing collection
            collectionQuotes.removeAll { $0.id == quoteId }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadCollections()
    }
}

// Extension to make CollectionWithCount mutable for quoteCount
extension CollectionWithCount {
    init(
        id: UUID,
        userId: UUID,
        name: String,
        coverImageUrl: String?,
        createdAt: String,
        updatedAt: String,
        quoteCount: Int
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.coverImageUrl = coverImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.quoteCount = quoteCount
    }
}
