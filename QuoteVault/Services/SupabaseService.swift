//
//  SupabaseService.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import Foundation
import Supabase

// MARK: - Supabase Client Singleton
@MainActor
final class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Constants.Supabase.url)!,
            supabaseKey: Constants.Supabase.anonKey,
            options: SupabaseClientOptions(
                auth: AuthClientOptions(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}

// MARK: - Network Error
enum NetworkError: LocalizedError {
    case invalidResponse
    case decodingError
    case serverError(String)
    case unauthorized
    case notFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "You need to sign in to perform this action"
        case .notFound:
            return "Resource not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
