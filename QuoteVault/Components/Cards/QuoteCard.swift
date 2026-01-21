//
//  QuoteCard.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct QuoteCard: View {
    let quote: QuoteWithCategory
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Category Label
                HStack {
                    Text(quote.categoryName)
                        .font(AppFont.medium(12))
                        .foregroundColor(CategoryColor.color(for: quote.categoryName))
                    
                    Spacer()
                    
                    Button {
                        HapticManager.shared.trigger(.selection)
                        onFavoriteToggle?()
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(isFavorite ? .red : .secondaryText)
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
                    }
                    .buttonStyle(.plain)
                }
                
                // Quote Text
                Text("\"\(quote.text)\"")
                    .font(AppFont.quoteFont(16))
                    .foregroundColor(.primaryText)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                // Author
                HStack(spacing: AppSpacing.sm) {
                    // Author Avatar Placeholder
                    Circle()
                        .fill(Color.secondaryBackground)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text(String(quote.author.prefix(2)).uppercased())
                                .font(AppFont.bold(10))
                                .foregroundColor(.secondaryText)
                        )
                    
                    Text(quote.author)
                        .font(AppFont.medium(14))
                        .foregroundColor(.secondaryText)
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(Color.appBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quote of the Day Card
struct QuoteOfDayCard: View {
    let quote: QuoteWithCategory
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)? = nil
    var onShare: (() -> Void)? = nil
    var onCopy: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header
            HStack {
                Text("Quote of the Day")
                    .font(AppFont.medium(12))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
                
                Spacer()
                
                Menu {
                    Button {
                        onShare?()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        onCopy?()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            
            // Quote Icon
            Image(systemName: "quote.opening")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.6))
            
            // Quote Text
            Text("\"\(quote.text)\"")
                .font(.system(size: 22, weight: .medium, design: .serif))
                .italic()
                .foregroundColor(.white)
                .lineLimit(4)
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 3)
            
            // Author
            Text(quote.author)
                .font(AppFont.semibold(16))
                .foregroundColor(.white)
            
            Spacer()
            
            // Action Bar
            HStack(spacing: AppSpacing.lg) {
                // Like Button
                Button {
                    HapticManager.shared.trigger(.selection)
                    onFavoriteToggle?()
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .scaleEffect(isFavorite ? 1.2 : 1.0)
                        Text("\(quote.likesCount > 0 ? formatNumber(quote.likesCount) : "")")
                    }
                    .font(AppFont.medium(14))
                    .foregroundColor(.white)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isFavorite)
                }
                
                // Comments
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "bubble.left")
                    Text("\(quote.commentsCount)")
                }
                .font(AppFont.medium(14))
                .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                // Copy Button
                Button {
                    onCopy?()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Share Button
                Button {
                    onShare?()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(AppSpacing.sm)
                        .background(Circle().fill(Color(hex: "4F46E5")))
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(height: 280)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1000 {
            return String(format: "%.1fk", Double(num) / 1000)
        }
        return "\(num)"
    }
}

#Preview {
    let sampleQuote = QuoteWithCategory(
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
            name: "Motivation",
            icon: "bolt.fill",
            color: "#4F46E5",
            createdAt: ""
        )
    )
    
    ScrollView {
        VStack(spacing: 20) {
            QuoteOfDayCard(quote: sampleQuote, isFavorite: true)
            QuoteCard(quote: sampleQuote, isFavorite: false)
        }
        .padding()
    }
}
