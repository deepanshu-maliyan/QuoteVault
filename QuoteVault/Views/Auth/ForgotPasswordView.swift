//
//  ForgotPasswordView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email = ""
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                // Header
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "4F46E5"))
                    
                    Text("Reset Password")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(AppFont.regular(14))
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.top, AppSpacing.xl)
                
                // Form
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Email Address")
                        .font(AppFont.medium(14))
                        .foregroundColor(.primaryText)
                    
                    CustomTextField(
                        placeholder: "you@example.com",
                        text: $email,
                        icon: "envelope",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                }
                .padding(.horizontal, AppSpacing.lg)
                
                // Reset Button
                PrimaryButton(
                    title: "Send Reset Link",
                    action: resetPassword,
                    isLoading: authService.isLoading,
                    isDisabled: !isFormValid,
                    icon: "paperplane.fill"
                )
                .padding(.horizontal, AppSpacing.lg)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .alert("Check Your Email", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("We've sent a password reset link to \(email)")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authService.error ?? "Please try again")
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    private func resetPassword() {
        Task {
            do {
                try await authService.resetPassword(email: email)
                showSuccess = true
            } catch {
                showError = true
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
