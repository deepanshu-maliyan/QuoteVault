//
//  DiscoverView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var selectedQuote: QuoteWithCategory?
    @State private var showQuoteDetail = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Discover")
                        .font(AppFont.bold(32))
                        .foregroundColor(.primaryText)
                    
                    SearchBar(
                        text: $viewModel.searchQuery,
                        placeholder: "Search quotes or authors...",
                        onSearch: {
                            viewModel.search()
                        }
                    )
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                
                // Category Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.categories) { category in
                            CategoryChip(
                                category: category,
                                isSelected: viewModel.selectedCategory.id == category.id,
                                onTap: {
                                    Task {
                                        await viewModel.selectCategory(category)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.sm)
                }
                
                // Content
                if viewModel.isLoading && viewModel.quotes.isEmpty {
                    LoadingView()
                } else if viewModel.quotes.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Quotes Found",
                        message: viewModel.searchQuery.isEmpty
                            ? "Try selecting a different category"
                            : "Try a different search term"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(viewModel.quotes) { quote in
                                QuoteCard(
                                    quote: quote,
                                    isFavorite: viewModel.isFavorited(quote.id),
                                    onFavoriteToggle: {
                                        Task {
                                            await viewModel.toggleFavorite(quoteId: quote.id)
                                        }
                                    },
                                    onTap: {
                                        selectedQuote = quote
                                        showQuoteDetail = true
                                    }
                                )
                                .onAppear {
                                    Task {
                                        await viewModel.loadMoreIfNeeded(currentQuote: quote)
                                    }
                                }
                            }
                            
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xxl)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .background(Color.appBackground)
            .task {
                await viewModel.loadInitialData()
            }
            .navigationDestination(isPresented: $showQuoteDetail) {
                if let quote = selectedQuote {
                    QuoteDetailView(quote: quote)
                }
            }
        }
    }
}

#Preview {
    DiscoverView()
}
