//
//  CustomTextField.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    @State private var isPasswordVisible = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.secondaryText)
                    .frame(width: 24)
            }
            
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .font(AppFont.regular(16))
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(AppFont.regular(16))
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .focused($isFocused)
            }
            
            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 18))
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(isFocused ? Color(hex: "4F46E5") : Color.gray.opacity(0.3), lineWidth: 1.5)
        )
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    var onSearch: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.secondaryText)
            
            TextField(placeholder, text: $text)
                .font(AppFont.regular(16))
                .textInputAutocapitalization(.never)
                .onChange(of: text) { _, _ in
                    onSearch?()
                }
            
            if !text.isEmpty {
                Button {
                    text = ""
                    onSearch?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(Color.secondaryBackground)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomTextField(
            placeholder: "you@example.com",
            text: .constant(""),
            icon: "envelope"
        )
        CustomTextField(
            placeholder: "Password",
            text: .constant("password"),
            icon: "lock",
            isSecure: true
        )
        SearchBar(text: .constant(""), placeholder: "Search quotes or authors...")
    }
    .padding()
}
