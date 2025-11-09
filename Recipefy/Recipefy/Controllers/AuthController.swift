//
//  AuthController.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/06/25.
//

import Foundation
import SwiftUI
import Combine
import AuthenticationServices

@MainActor
final class AuthController: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    // MARK: - Mock Authentication (MVP)
    
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Mock success - always authenticate
        isAuthenticated = true
        isLoading = false
        
        print("Mock sign in successful for: \(email)")
    }
    
    func signUp(email: String, password: String, username: String) async {
        errorMessage = nil
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Mock success - always authenticate
        isAuthenticated = true
        isLoading = false
        
        print("Mock sign up successful for: \(username) (\(email))")
    }
    
    func signInWithGoogle() async {
        errorMessage = nil
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Mock success
        isAuthenticated = true
        isLoading = false
        
        print("Mock Google sign in successful")
    }
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        errorMessage = nil
        isLoading = true
        
        switch result {
        case .success(let authorization):
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Mock success
            isAuthenticated = true
            isLoading = false
            
            print("Mock Apple sign in successful")
            
        case .failure(let error):
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            isLoading = false
            print("Apple Sign In error: \(error)")
        }
    }
    
    func signOut() {
        isAuthenticated = false
        errorMessage = nil
        print("User signed out")
    }
}
