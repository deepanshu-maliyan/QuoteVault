//
//  SettingsView.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var authService = AuthService.shared
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    HStack(spacing: AppSpacing.md) {
                        AvatarView(
                            imageUrl: authService.currentProfile?.avatarUrl,
                            name: viewModel.displayName,
                            size: 60
                        )
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(viewModel.displayName.isEmpty ? "User" : viewModel.displayName)
                                .font(AppFont.semibold(18))
                                .foregroundColor(.primaryText)
                            
                            Text("Quote Enthusiast")
                                .font(AppFont.regular(14))
                                .foregroundColor(.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button {
                            // Edit profile
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "4F46E5"))
                        }
                    }
                    .padding(.vertical, AppSpacing.sm)
                }
                
                // Appearance Section
                Section("Appearance") {
                    // Theme
                    HStack {
                        Label("Theme", systemImage: "moon.circle")
                        
                        Spacer()
                        
                        Picker("", selection: $viewModel.selectedTheme) {
                            ForEach(ThemeMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue.capitalized).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                    
                    // Accent Color
                    HStack {
                        Label("Accent Color", systemImage: "paintpalette")
                        
                        Spacer()
                        
                        HStack(spacing: AppSpacing.sm) {
                            ForEach(AppColor.allCases, id: \.self) { color in
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                viewModel.selectedAccentColor == color
                                                    ? Color.primaryText
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                            .padding(2)
                                    )
                                    .onTapGesture {
                                        viewModel.selectedAccentColor = color
                                    }
                            }
                        }
                    }
                    
                    // Font Size
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack {
                            Label("Font Size", systemImage: "textformat.size")
                            
                            Spacer()
                            
                            Text("\(Int(viewModel.fontSize))px")
                                .font(AppFont.medium(14))
                                .foregroundColor(Color(hex: "4F46E5"))
                        }
                        
                        HStack {
                            Text("T")
                                .font(.system(size: 12))
                                .foregroundColor(.secondaryText)
                            
                            Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                                .tint(Color(hex: "4F46E5"))
                            
                            Text("T")
                                .font(.system(size: 20))
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle(isOn: $viewModel.notificationEnabled) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Daily Inspiration")
                            }
                            Text("Get a quote every morning")
                                .font(AppFont.regular(12))
                                .foregroundColor(.secondaryText)
                        }
                    }
                    .tint(Color(hex: "4F46E5"))
                    
                    if viewModel.notificationEnabled {
                        DatePicker(
                            selection: $viewModel.notificationTime,
                            displayedComponents: .hourAndMinute
                        ) {
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "clock")
                                    .foregroundColor(Color(hex: "4F46E5"))
                                Text("Time")
                            }
                        }
                    }
                }
                
                // Save Button
                Section {
                    Button {
                        Task {
                            await viewModel.saveSettings()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            } else if viewModel.showSaveSuccess {
                                HStack(spacing: AppSpacing.sm) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Saved!")
                                }
                            } else {
                                Text("Save Changes")
                            }
                            Spacer()
                        }
                        .font(AppFont.semibold(16))
                        .foregroundColor(.white)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.md)
                                .fill(Color(hex: "4F46E5"))
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
                
                // Logout Section
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            HStack(spacing: AppSpacing.sm) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                            .font(AppFont.semibold(16))
                            .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                // App Info
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: AppSpacing.xs) {
                            Text("QuoteVault")
                                .font(AppFont.medium(14))
                                .foregroundColor(.secondaryText)
                            Text("Version 1.0.0 (Build 1)")
                                .font(AppFont.regular(12))
                                .foregroundColor(.tertiaryText)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadSettings()
            }
            .alert("Log Out?", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    Task {
                        try? await viewModel.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

#Preview {
    SettingsView()
}
