//
//  WelcomeView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct WelcomeView: View {
    @State private var navigateToLogin = false
    @State private var navigateToSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color(hex: "E0E7FF").opacity(0.5),
                        Color.appBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.xl) {
                    Spacer()
                    
                    // Logo
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
                            Text("QuoteVault")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            Text(Constants.App.tagline)
                                .font(AppFont.regular(16))
                                .foregroundColor(.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.xl)
                        }
                    }
                    
                    Spacer()
                    
                    // Hero Image Placeholder
                    RoundedRectangle(cornerRadius: AppRadius.xl)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "A7F3D0"), Color(hex: "6EE7B7")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "infinity")
                                .font(.system(size: 80, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.8))
                        )
                        .padding(.horizontal, AppSpacing.xl)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: AppSpacing.md) {
                        PrimaryButton(title: "Sign Up for Free") {
                            navigateToSignUp = true
                        }
                        
                        SecondaryButton(title: "Log In") {
                            navigateToLogin = true
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
