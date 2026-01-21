//
//  HomeView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var authService = AuthService.shared
    @StateObject private var navigation = NavigationManager.shared
    @StateObject private var stateManager = AppStateManager.shared
    @State private var showQuoteDetail = false
    @State private var selectedQuote: QuoteWithCategory?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Header
                    headerSection
                    
                    // Quote of the Day
                    if let quote = viewModel.quoteOfDay {
                        quoteOfDaySection(quote: quote)
                    }
                    
                    // Categories
                    categoriesSection
                    
                    // Recommended Quotes
                    recommendedSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.xxl)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .background(Color.appBackground)
            .task {
                await viewModel.loadHomeData()
            }
            .navigationDestination(isPresented: $showQuoteDetail) {
                if let quote = selectedQuote {
                    QuoteDetailView(quote: quote)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Daily Inspiration")
                    .font(AppFont.regular(12))
                    .foregroundColor(.secondaryText)
                
                Text("\(viewModel.getGreeting()), \(viewModel.getUserDisplayName())")
                    .font(AppFont.bold(24))
                    .foregroundColor(.primaryText)
            }
            
            Spacer()
            
            AvatarView(
                imageUrl: authService.currentProfile?.avatarUrl,
                name: viewModel.getUserDisplayName(),
                size: 44
            )
            .overlay(
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                    .offset(x: 2, y: 2),
                alignment: .bottomTrailing
            )
        }
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - Quote of the Day Section
    @ViewBuilder
    private func quoteOfDaySection(quote: QuoteWithCategory) -> some View {
        QuoteOfDayCard(
            quote: quote,
            isFavorite: viewModel.isFavorited(quote.id),
            onFavoriteToggle: {
                Task {
                    await viewModel.toggleFavorite(quoteId: quote.id)
                }
            },
            onShare: {
                shareQuote(quote)
            },
            onCopy: {
                copyQuote(quote)
            }
        )
        .onTapGesture {
            selectedQuote = quote
            showQuoteDetail = true
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Categories")
                    .font(AppFont.semibold(18))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button {
                    navigation.switchToTab(1)
                } label: {
                    Text("View all")
                        .font(AppFont.medium(14))
                        .foregroundColor(stateManager.accentColor.color)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    CategoryPillButton(
                        name: "All",
                        icon: "square.grid.2x2.fill",
                        isSelected: viewModel.selectedCategoryId == nil
                    ) {
                        Task {
                            await viewModel.selectCategory(id: nil)
                        }
                    }
                    
                    ForEach(viewModel.categories) { category in
                        CategoryPillButton(
                            name: category.name,
                            icon: category.systemIcon,
                            isSelected: viewModel.selectedCategoryId == category.id
                        ) {
                            Task {
                                await viewModel.selectCategory(id: category.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Recommended Section
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Recommended for You")
                .font(AppFont.semibold(18))
                .foregroundColor(.primaryText)
            
            if viewModel.isLoading && viewModel.recommendedQuotes.isEmpty {
                LoadingView()
                    .frame(height: 200)
            } else if viewModel.recommendedQuotes.isEmpty {
                EmptyStateView(
                    icon: "quote.bubble",
                    title: "No Quotes",
                    message: "Check back later for recommendations"
                )
                .frame(height: 200)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: AppSpacing.md),
                    GridItem(.flexible(), spacing: AppSpacing.md)
                ], spacing: AppSpacing.md) {
                    ForEach(viewModel.recommendedQuotes.prefix(4)) { quote in
                        RecommendedQuoteCard(
                            quote: quote,
                            isFavorite: viewModel.isFavorited(quote.id),
                            onFavoriteToggle: {
                                Task {
                                    await viewModel.toggleFavorite(quoteId: quote.id)
                                }
                            }
                        )
                        .onTapGesture {
                            selectedQuote = quote
                            showQuoteDetail = true
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func shareQuote(_ quote: QuoteWithCategory) {
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
    
    private func copyQuote(_ quote: QuoteWithCategory) {
        UIPasteboard.general.string = "\"\(quote.text)\" — \(quote.author)"
    }
}

// MARK: - Category Pill Button
struct CategoryPillButton: View {
    let name: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var stateManager: AppStateManager
    
    var body: some View {
        Button {
            HapticManager.shared.trigger(.selection)
            action()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(name)
                    .font(AppFont.medium(14))
            }
            .foregroundColor(isSelected ? .white : .primaryText)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? stateManager.accentColor.color : Color.secondaryBackground)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recommended Quote Card
struct RecommendedQuoteCard: View {
    let quote: QuoteWithCategory
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Quote Icon & Favorite
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "4F46E5").opacity(0.6))
                
                Spacer()
                
                Button {
                    onFavoriteToggle?()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14))
                        .foregroundColor(isFavorite ? .red : .secondaryText)
                }
            }
            
            // Quote Text
            Text("\"\(quote.text)\"")
                .font(AppFont.medium(14))
                .foregroundColor(.primaryText)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Author
            HStack(spacing: AppSpacing.xs) {
                Circle()
                    .fill(Color.secondaryBackground)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(String(quote.author.prefix(1)).uppercased())
                            .font(AppFont.bold(10))
                            .foregroundColor(.secondaryText)
                    )
                
                Text(quote.author)
                    .font(AppFont.medium(12))
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(AppSpacing.md)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.appBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    HomeView()
}
