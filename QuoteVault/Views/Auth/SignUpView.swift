//
//  SignUpView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showLogin = false
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Header
                VStack(spacing: AppSpacing.lg) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(Color(hex: "4F46E5"))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "quote.opening")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: AppSpacing.sm) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primaryText)
                        
                        Text("Start your journey of inspiration")
                            .font(AppFont.regular(16))
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.top, AppSpacing.lg)
                
                // Form
                VStack(spacing: AppSpacing.lg) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Display Name")
                            .font(AppFont.medium(14))
                            .foregroundColor(.primaryText)
                        
                        CustomTextField(
                            placeholder: "Your name",
                            text: $displayName,
                            icon: "person"
                        )
                    }
                    
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
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Password")
                            .font(AppFont.medium(14))
                            .foregroundColor(.primaryText)
                        
                        CustomTextField(
                            placeholder: "At least 6 characters",
                            text: $password,
                            icon: "lock",
                            isSecure: true
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Confirm Password")
                            .font(AppFont.medium(14))
                            .foregroundColor(.primaryText)
                        
                        CustomTextField(
                            placeholder: "Re-enter password",
                            text: $confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        
                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwords don't match")
                                .font(AppFont.regular(12))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                
                // Sign Up Button
                VStack(spacing: AppSpacing.lg) {
                    PrimaryButton(
                        title: "Create Account",
                        action: signUp,
                        isLoading: authService.isLoading,
                        isDisabled: !isFormValid,
                        icon: "arrow.right"
                    )
                    .padding(.horizontal, AppSpacing.lg)
                }
                
                Spacer(minLength: AppSpacing.lg)
                
                // Login Link
                HStack(spacing: AppSpacing.xs) {
                    Text("Already have an account?")
                        .font(AppFont.regular(14))
                        .foregroundColor(.secondaryText)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Log In")
                            .font(AppFont.semibold(14))
                            .foregroundColor(Color(hex: "4F46E5"))
                    }
                }
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
        .alert("Sign Up Failed", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authService.error ?? "Please try again")
        }
        .onChange(of: authService.error) { _, error in
            if error != nil {
                showError = true
            }
        }
    }
    
    private var isFormValid: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func signUp() {
        Task {
            do {
                try await authService.signUp(
                    email: email,
                    password: password,
                    displayName: displayName
                )
            } catch {
                // Error is handled by authService
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
