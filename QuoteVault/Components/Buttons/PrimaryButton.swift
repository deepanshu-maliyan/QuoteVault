//
//  PrimaryButton.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var icon: String? = nil
    
    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.light)
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(AppFont.semibold(16))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(isDisabled ? Color.gray.opacity(0.3) : AppStateManager.shared.accentColor.color)
            )
            .opacity(isDisabled ? 0.6 : 1)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    
    @StateObject private var stateManager = AppStateManager.shared
    
    var body: some View {
        Button(action: {
            HapticManager.shared.trigger(.light)
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: stateManager.accentColor.color))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(AppFont.semibold(16))
                }
            }
            .foregroundColor(stateManager.accentColor.color)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(stateManager.accentColor.color.opacity(0.3), lineWidth: 1.5)
            )
        }
        .disabled(isLoading)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Sign Up for Free", action: {})
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        SecondaryButton(title: "Log In", action: {})
    }
    .padding()
}
