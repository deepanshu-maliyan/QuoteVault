//
//  AuthService.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import Supabase
import Auth

// MARK: - Auth Service
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var currentProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let supabase = SupabaseService.shared.client
    
    private init() {
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Check Current Session
    func checkSession() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.session
            currentUser = session.user
            isAuthenticated = true
            await fetchProfile()
        } catch {
            currentUser = nil
            currentProfile = nil
            isAuthenticated = false
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: ["display_name": .string(displayName)]
            )
            
            currentUser = response.user
            isAuthenticated = true
            await fetchProfile()
        } catch let authError as AuthError {
            self.error = authError.localizedDescription
            throw authError
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            currentUser = session.user
            isAuthenticated = true
            await fetchProfile()
        } catch let authError as AuthError {
            self.error = authError.localizedDescription
            throw authError
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            try await supabase.auth.signOut()
            currentUser = nil
            currentProfile = nil
            isAuthenticated = false
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Fetch User Profile
    func fetchProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let profile: UserProfile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            currentProfile = profile
        } catch {
            print("Error fetching profile: \(error)")
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(_ update: ProfileUpdateRequest) async throws {
        guard let userId = currentUser?.id else {
            throw NetworkError.unauthorized
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase
                .from("profiles")
                .update(update)
                .eq("id", value: userId.uuidString)
                .execute()
            
            await fetchProfile()
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
}
