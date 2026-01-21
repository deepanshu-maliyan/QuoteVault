//
//  CollectionsManager.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI
import Combine

@MainActor
class CollectionsManager: ObservableObject {
    @Published var collections: [CollectionWithCount] = []
    @Published var collectionQuotes: [QuoteWithCategory] = []
    @Published var isLoading = false
    @Published var error: String?
    
    static let shared = CollectionsManager()
    private let collectionService = CollectionService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Listen to profile changes to load collections
        AuthService.shared.$currentProfile
            .compactMap { $0 }
            .sink { [weak self] _ in
                Task {
                    await self?.loadCollections()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadCollections() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        isLoading = true
        do {
            self.collections = try await collectionService.fetchCollections(userId: userId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func createCollection(name: String) async -> UUID? {
        guard let userId = AuthService.shared.currentUser?.id else { return nil }
        
        do {
            let collection = try await collectionService.createCollection(name: name, userId: userId)
            let newCollection = CollectionWithCount(from: collection, quoteCount: 0)
            await MainActor.run {
                collections.insert(newCollection, at: 0)
                HapticManager.shared.trigger(.success)
            }
            return collection.id
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
            return nil
        }
    }
    
    func loadCollectionQuotes(collectionId: UUID) async {
        isLoading = true
        do {
            self.collectionQuotes = try await collectionService.fetchCollectionQuotes(collectionId: collectionId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func addQuote(quoteId: UUID, collectionId: UUID) async {
        do {
            try await collectionService.addQuoteToCollection(quoteId: quoteId, collectionId: collectionId)
            await MainActor.run {
                if let index = collections.firstIndex(where: { $0.id == collectionId }) {
                    var updated = collections[index]
                    updated.quoteCount += 1
                    collections[index] = updated
                    HapticManager.shared.trigger(.success)
                }
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    func removeQuote(quoteId: UUID, collectionId: UUID) async {
        do {
            try await collectionService.removeQuoteFromCollection(quoteId: quoteId, collectionId: collectionId)
            await MainActor.run {
                // Update quote count in collections list
                if let index = collections.firstIndex(where: { $0.id == collectionId }) {
                    var updated = collections[index]
                    updated.quoteCount = max(0, updated.quoteCount - 1)
                    collections[index] = updated
                }
                // Remove from current collection quotes view
                collectionQuotes.removeAll { $0.id == quoteId }
                HapticManager.shared.trigger(.light)
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    func updateCollection(id: UUID, name: String) async {
        do {
            try await collectionService.updateCollection(id: id, name: name)
            await MainActor.run {
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
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
    
    func deleteCollection(id: UUID) async {
        do {
            try await collectionService.deleteCollection(id: id)
            await MainActor.run {
                collections.removeAll { $0.id == id }
                HapticManager.shared.trigger(.warning)
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
            }
        }
    }
}
