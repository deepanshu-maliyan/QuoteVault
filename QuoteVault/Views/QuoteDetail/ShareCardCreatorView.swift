//
//  ShareCardCreatorView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

// MARK: - Card Style
enum CardStyle: String, CaseIterable, Identifiable {
    case ocean = "Ocean"
    case clean = "Clean"
    case nature = "Nature"
    case noir = "Noir"
    
    var id: String { rawValue }
    
    var background: AnyView {
        switch self {
        case .ocean:
            return AnyView(
                LinearGradient(
                    colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .clean:
            return AnyView(Color.white)
        case .nature:
            return AnyView(
                LinearGradient(
                    colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .noir:
            return AnyView(Color(hex: "1F2937"))
        }
    }
    
    var textColor: Color {
        switch self {
        case .ocean, .nature, .noir:
            return .white
        case .clean:
            return .black
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .ocean, .nature:
            return .white.opacity(0.8)
        case .clean:
            return Color(hex: "6B7280")
        case .noir:
            return .white.opacity(0.6)
        }
    }
    
    var previewBackground: some View {
        switch self {
        case .ocean:
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
        case .clean:
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        case .nature:
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(
                        colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
        case .noir:
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "1F2937"))
            )
        }
    }
}

// MARK: - Share Card Creator View
struct ShareCardCreatorView: View {
    let quote: QuoteWithCategory
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: CardStyle = .ocean
    @State private var cardImage: UIImage?
    @State private var showingSaveSuccess = false
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Card Preview
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Preview Card
                        ShareCardView(quote: quote, style: selectedStyle)
                            .frame(height: 400)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.lg)
                        
                        // Style Selector
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            HStack {
                                Text("CHOOSE STYLE")
                                    .font(AppFont.medium(12))
                                    .foregroundColor(.secondaryText)
                                    .tracking(1)
                                
                                Spacer()
                                
                                Button("See All") {
                                    // Show more styles
                                }
                                .font(AppFont.medium(12))
                                .foregroundColor(Color(hex: "4F46E5"))
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.md) {
                                    ForEach(CardStyle.allCases) { style in
                                        StylePreviewButton(
                                            style: style,
                                            isSelected: selectedStyle == style
                                        ) {
                                            withAnimation {
                                                selectedStyle = style
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
                
                // Action Buttons
                HStack(spacing: AppSpacing.md) {
                    Button {
                        saveCardToPhotos()
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "arrow.down.to.line")
                            Text("Save")
                        }
                        .font(AppFont.semibold(14))
                        .foregroundColor(.primaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
                        )
                    }
                    
                    Button {
                        shareCard()
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Card")
                        }
                        .font(AppFont.semibold(14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(Color(hex: "4F46E5"))
                        )
                    }
                }
                .padding(AppSpacing.lg)
            }
            .background(Color.appBackground)
            .navigationTitle("Create Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(AppFont.semibold(16))
                    .foregroundColor(Color(hex: "4F46E5"))
                }
            }
            .alert("Saved!", isPresented: $showingSaveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The quote card has been saved to your photo library.")
            }
        }
    }
    
    @MainActor
    private func saveCardToPhotos() {
        let renderer = ImageRenderer(content: ShareCardView(quote: quote, style: selectedStyle).frame(width: 400, height: 500))
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            ImageSaver().writeToPhotoAlbum(image: image) { error in
                if error == nil {
                    showingSaveSuccess = true
                }
            }
        }
    }
    
    @MainActor
    private func shareCard() {
        // Create a dedicated container for rendering to ensure consistent style and size
        let renderView = ShareCardView(quote: quote, style: selectedStyle)
            .frame(width: 400, height: 500)
        
        let renderer = ImageRenderer(content: renderView)
        renderer.scale = UIScreen.main.scale // Use device scale for better quality
        
        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            
            // For iPad compatibility
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                rootVC.present(activityVC, animated: true)
            }
        } else {
            print("Failed to render image for sharing")
        }
    }
}

// MARK: - Image Saver Helper
class ImageSaver: NSObject {
    private var completion: ((Error?) -> Void)?

    func writeToPhotoAlbum(image: UIImage, completion: @escaping (Error?) -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async {
            self.completion?(error)
        }
    }
}

// MARK: - Share Card View
struct ShareCardView: View {
    let quote: QuoteWithCategory
    let style: CardStyle
    
    var body: some View {
        ZStack {
            style.background
            
            VStack(spacing: AppSpacing.lg) {
                Spacer()
                
                // Quote Icon
                Image(systemName: "quote.opening")
                    .font(.system(size: 40))
                    .foregroundColor(style.secondaryTextColor)
                
                // Quote Text
                Text("\"\(quote.text)\"")
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(style.textColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, AppSpacing.lg)
                
                // Author
                Text("— \(quote.author)")
                    .font(AppFont.medium(16))
                    .foregroundColor(style.secondaryTextColor)
                
                Spacer()
                
                // Branding
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 12))
                    Text("QUOTEVAULT")
                        .font(AppFont.bold(10))
                        .tracking(2)
                }
                .foregroundColor(style.secondaryTextColor)
                .padding(.bottom, AppSpacing.lg)
            }
            .padding(AppSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
    }
}

// MARK: - Style Preview Button
struct StylePreviewButton: View {
    let style: CardStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    style.previewBackground
                        .frame(width: 60, height: 80)
                    
                    Text("Aa")
                        .font(AppFont.semibold(16))
                        .foregroundColor(style.textColor)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color(hex: "4F46E5") : Color.clear, lineWidth: 3)
                )
                
                Text(style.rawValue)
                    .font(AppFont.medium(12))
                    .foregroundColor(isSelected ? Color(hex: "4F46E5") : .secondaryText)
            }
        }
    }
}

#Preview {
    ShareCardCreatorView(
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
            categories: nil
        )
    )
}
