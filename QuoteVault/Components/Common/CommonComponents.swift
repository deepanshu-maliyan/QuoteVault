//
//  CommonComponents.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text(message)
                .font(AppFont.regular(14))
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondaryText.opacity(0.5))
            
            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppFont.semibold(18))
                    .foregroundColor(.primaryText)
                
                Text(message)
                    .font(AppFont.regular(14))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppFont.semibold(14))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(Color(hex: "4F46E5"))
                        )
                }
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(AppFont.semibold(18))
                .foregroundColor(.primaryText)
            
            Text(message)
                .font(AppFont.regular(14))
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(AppFont.semibold(14))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .fill(Color(hex: "4F46E5"))
                    )
                }
            }
        }
        .padding(AppSpacing.xl)
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    var imageUrl: String? = nil
    var name: String = ""
    var size: CGFloat = 40
    
    var body: some View {
        Group {
            if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    initialsView
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
    
    private var initialsView: some View {
        Circle()
            .fill(Color(hex: "E0E7FF"))
            .overlay(
                Text(String(name.prefix(2)).uppercased())
                    .font(AppFont.bold(size * 0.35))
                    .foregroundColor(Color(hex: "4F46E5"))
            )
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: CategoryFilter
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                if isSelected {
                    Image(systemName: category.icon)
                        .font(.system(size: 12))
                }
                Text(category.name)
                    .font(AppFont.medium(14))
            }
            .foregroundColor(isSelected ? .white : .primaryText)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: "4F46E5") : Color.secondaryBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView()
        
        EmptyStateView(
            icon: "heart.slash",
            title: "No Favorites Yet",
            message: "Start saving quotes you love!",
            actionTitle: "Browse Quotes",
            action: {}
        )
        
        AvatarView(name: "John Doe", size: 60)
        
        HStack {
            CategoryChip(category: .all, isSelected: true)
            CategoryChip(category: CategoryFilter(id: UUID(), name: "Wisdom", icon: "brain.head.profile", color: .green))
        }
    }
}
