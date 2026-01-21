//
//  QuoteDetailView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct QuoteDetailView: View {
    let quote: QuoteWithCategory
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @StateObject private var collectionsManager = CollectionsManager.shared
    
    private let favoriteService = FavoriteService.shared
    
    @State private var isFavorite = false
    @State private var showShareSheet = false
    @State private var showCardCreator = false
    @State private var showAddToCollection = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                // Category Badge
                HStack {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text(quote.categoryName)
                            .font(AppFont.medium(12))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        Capsule()
                            .fill(CategoryColor.color(for: quote.categoryName))
                    )
                    
                    Spacer()
                }
                
                // Date Added
                Text("ADDED \(formattedDate)")
                    .font(AppFont.medium(11))
                    .foregroundColor(.secondaryText)
                    .tracking(1)
                
                // Quote Text
                Text(quote.text)
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundColor(.primaryText)
                    .lineSpacing(8)
                
                // Author
                HStack {
                    Rectangle()
                        .fill(Color(hex: "4F46E5"))
                        .frame(width: 40, height: 3)
                    
                    Text(quote.author)
                        .font(AppFont.medium(16))
                        .foregroundColor(.secondaryText)
                }
                
                Spacer(minLength: AppSpacing.xxl)
                
                // Action Buttons
                HStack(spacing: AppSpacing.lg) {
                    // Share
                    ActionButton(icon: "square.and.arrow.up", label: "Share") {
                        shareQuote()
                    }
                    
                    // Create Card
                    ActionButton(icon: "rectangle.portrait.on.rectangle.portrait", label: "Card") {
                        showCardCreator = true
                    }
                    
                    Spacer()
                    
                    // Save Quote
                    Button {
                        showAddToCollection = true
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "bookmark.fill")
                            Text("Save Quote")
                        }
                        .font(AppFont.semibold(14))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(AppStateManager.shared.accentColor.color)
                        )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(Color.appBackground)
        .navigationTitle("Quote Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        Task {
                            await toggleFavorite()
                        }
                    } label: {
                        Label(
                            isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    
                    Button {
                        showAddToCollection = true
                    } label: {
                        Label("Add to Collection", systemImage: "folder.badge.plus")
                    }
                    
                    Button {
                        copyQuote()
                    } label: {
                        Label("Copy Quote", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await checkFavoriteStatus()
            await collectionsManager.loadCollections()
        }
        .sheet(isPresented: $showCardCreator) {
            ShareCardCreatorView(quote: quote)
        }
        .sheet(isPresented: $showAddToCollection) {
            AddToCollectionSheet(
                quote: quote,
                collections: collectionsManager.collections,
                onAdd: { collectionId in
                    Task {
                        await collectionsManager.addQuote(
                            quoteId: quote.id,
                            collectionId: collectionId
                        )
                        showAddToCollection = false
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: Date()).uppercased()
    }
    
    private func checkFavoriteStatus() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            isFavorite = try await favoriteService.isFavorited(quoteId: quote.id, userId: userId)
        } catch {
            print("Error checking favorite status: \(error)")
        }
    }
    
    private func toggleFavorite() async {
        guard let userId = authService.currentUser?.id else { return }
        do {
            isFavorite = try await favoriteService.toggleFavorite(quoteId: quote.id, userId: userId)
        } catch {
            print("Error toggling favorite: \(error)")
        }
    }
    
    private func shareQuote() {
        let text = "\"\(quote.text)\" — \(quote.author)"
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func copyQuote() {
        UIPasteboard.general.string = "\"\(quote.text)\" — \(quote.author)"
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(AppFont.regular(12))
            }
            .foregroundColor(.secondaryText)
        }
    }
}

// MARK: - Add to Collection Sheet
struct AddToCollectionSheet: View {
    let quote: QuoteWithCategory
    let collections: [CollectionWithCount]
    let onAdd: (UUID) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(collections) { collection in
                    Button {
                        onAdd(collection.id)
                    } label: {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(Color(hex: "4F46E5"))
                            
                            VStack(alignment: .leading) {
                                Text(collection.name)
                                    .font(AppFont.medium(16))
                                    .foregroundColor(.primaryText)
                                
                                Text("\(collection.quoteCount) quotes")
                                    .font(AppFont.regular(12))
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle")
                                .foregroundColor(Color(hex: "4F46E5"))
                        }
                    }
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuoteDetailView(
            quote: QuoteWithCategory(
                id: UUID(),
                text: "The only way to do great work is to love what you do.",
                author: "Steve Jobs",
                authorImageUrl: nil,
                categoryId: UUID(),
                likesCount: 2400,
                commentsCount: 142,
                isQuoteOfDay: true,
                quoteOfDayDate: nil,
                createdAt: "",
                categories: CategoryResponse(
                    id: UUID(),
                    name: "Wisdom",
                    icon: "brain.head.profile",
                    color: "#10B981",
                    createdAt: ""
                )
            )
        )
    }
}
