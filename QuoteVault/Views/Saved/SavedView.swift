//
//  SavedView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct SavedView: View {
    @State private var selectedTab = 0
    @State private var showNewCollectionSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Segmented Control
                VStack(spacing: AppSpacing.lg) { // Increased spacing from md to lg
                    HStack {
                        Text("My Collections")
                            .font(AppFont.bold(28))
                            .foregroundColor(.primaryText)
                        
                        Spacer()
                        
                        Button {
                            showNewCollectionSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppStateManager.shared.accentColor.color)
                        }
                    }
                }
                    
                    // Segmented Control
                    HStack(spacing: 0) {
                        SegmentButton(title: "Favorites", isSelected: selectedTab == 0) {
                            withAnimation {
                                selectedTab = 0
                            }
                        }
                        
                        SegmentButton(title: "Collections", isSelected: selectedTab == 1) {
                            withAnimation {
                                selectedTab = 1
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .fill(Color.secondaryBackground)
                    )
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                
                // Content
                TabView(selection: $selectedTab) {
                    FavoritesListView()
                        .tag(0)
                    
                    CollectionsGridView(showNewCollectionSheet: $showNewCollectionSheet)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.appBackground)
        }
    }


// MARK: - Segment Button
struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.semibold(14))
                .foregroundColor(isSelected ? .white : .secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.sm)
                        .fill(isSelected ? AppStateManager.shared.accentColor.color : Color.clear)
                )
        }
        .padding(4)
    }
}

// MARK: - Favorites List View
struct FavoritesListView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedQuote: QuoteWithCategory?
    @State private var showQuoteDetail = false
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.favorites.isEmpty {
                LoadingView()
            } else if viewModel.favorites.isEmpty {
                EmptyStateView(
                    icon: "heart.slash",
                    title: "No Favorites Yet",
                    message: "Start saving quotes you love by tapping the heart icon"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.favorites) { favorite in
                            QuoteCard(
                                quote: favorite.quotes,
                                isFavorite: true,
                                onFavoriteToggle: {
                                    Task {
                                        await viewModel.removeFavorite(quoteId: favorite.quoteId)
                                    }
                                },
                                onTap: {
                                    selectedQuote = favorite.quotes
                                    showQuoteDetail = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .task {
            await viewModel.loadFavorites()
        }
        .navigationDestination(isPresented: $showQuoteDetail) {
            if let quote = selectedQuote {
                QuoteDetailView(quote: quote)
            }
        }
    }
}

// MARK: - Collections Grid View
struct CollectionsGridView: View {
    @StateObject private var collectionsManager = CollectionsManager.shared
    @Binding var showNewCollectionSheet: Bool
    @State private var newCollectionName = ""
    @State private var selectedCollection: CollectionWithCount?
    
    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]
    
    var body: some View {
        Group {
            if collectionsManager.isLoading && collectionsManager.collections.isEmpty {
                LoadingView()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        // New Collection Button
                        Button {
                            showNewCollectionSheet = true
                        } label: {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                                    .foregroundColor(.secondaryText)
                                
                                Text("New Collection")
                                    .font(AppFont.medium(14))
                                    .foregroundColor(.secondaryText)
                            }
                            .frame(height: 160)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.lg)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [8])
                                    )
                                    .foregroundColor(.gray.opacity(0.3))
                            )
                        }
                        
                        // Collections
                        ForEach(collectionsManager.collections) { collection in
                            CollectionCard(collection: collection)
                                .onTapGesture {
                                    selectedCollection = collection
                                }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.md)
                }
                .refreshable {
                    await collectionsManager.loadCollections()
                }
            }
        }
        .task {
            await collectionsManager.loadCollections()
        }
        .sheet(isPresented: $showNewCollectionSheet) {
            NewCollectionSheet(
                name: $newCollectionName,
                onCreate: {
                    Task {
                        _ = await collectionsManager.createCollection(name: newCollectionName)
                        newCollectionName = ""
                        showNewCollectionSheet = false
                    }
                }
            )
            .presentationDetents([.height(250)])
        }
        .navigationDestination(item: $selectedCollection) { collection in
            CollectionDetailView(collection: collection)
        }
    }
}

// MARK: - Collection Card
struct CollectionCard: View {
    let collection: CollectionWithCount
    
    private let gradients: [LinearGradient] = [
        LinearGradient(colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "06B6D4"), Color(hex: "10B981")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "EC4899"), Color(hex: "8B5CF6")], startPoint: .topLeading, endPoint: .bottomTrailing)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Cover
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(gradients[abs(collection.name.hashValue) % gradients.count])
                .frame(height: 100)
                .overlay(
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.5))
                )
            
            // Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(collection.name)
                    .font(AppFont.semibold(14))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                
                Text("\(collection.quoteCount) quotes")
                    .font(AppFont.regular(12))
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - New Collection Sheet
struct NewCollectionSheet: View {
    @Binding var name: String
    let onCreate: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                CustomTextField(
                    placeholder: "Collection name",
                    text: $name,
                    icon: "folder"
                )
                .padding(.horizontal, AppSpacing.md)
                
                PrimaryButton(title: "Create Collection", action: onCreate, isDisabled: name.isEmpty)
                    .padding(.horizontal, AppSpacing.md)
                
                Spacer()
            }
            .padding(.top, AppSpacing.lg)
            .navigationTitle("New Collection")
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
    SavedView()
}
