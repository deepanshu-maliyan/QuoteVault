//
//  LoginView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var showSignUp = false
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                // Header
                VStack(spacing: AppSpacing.lg) {
                    // Logo
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(Color(hex: "4F46E5"))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "quote.opening")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: AppSpacing.sm) {
                        Text("QuoteVault")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primaryText)
                        
                        Text("Sign in to find your inspiration")
                            .font(AppFont.regular(16))
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.top, AppSpacing.xxl)
                
                // Form
                VStack(spacing: AppSpacing.lg) {
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
                            placeholder: "••••••••",
                            text: $password,
                            icon: "lock",
                            isSecure: true
                        )
                        
                        HStack {
                            Spacer()
                            Button {
                                showForgotPassword = true
                            } label: {
                                Text("Forgot Password?")
                                    .font(AppFont.medium(14))
                                    .foregroundColor(Color(hex: "4F46E5"))
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                
                // Login Button
                VStack(spacing: AppSpacing.lg) {
                    PrimaryButton(
                        title: "Log In",
                        action: login,
                        isLoading: authService.isLoading,
                        isDisabled: !isFormValid,
                        icon: "arrow.right"
                    )
                    .padding(.horizontal, AppSpacing.lg)
                }
                
                Spacer(minLength: AppSpacing.xxl)
                
                // Sign Up Link
                HStack(spacing: AppSpacing.xs) {
                    Text("Don't have an account?")
                        .font(AppFont.regular(14))
                        .foregroundColor(.secondaryText)
                    
                    Button {
                        showSignUp = true
                    } label: {
                        Text("Sign Up")
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
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .navigationDestination(isPresented: $showSignUp) {
            SignUpView()
        }
        .alert("Login Failed", isPresented: $showError) {
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
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func login() {
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                // Error is handled by authService
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
