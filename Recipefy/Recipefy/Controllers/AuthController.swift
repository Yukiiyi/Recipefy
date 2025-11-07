//
//  AuthController.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/06/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
final class AuthController: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var userName: String?

    init() {
        print("Mock AuthController initialized (no Firebase connected)")
        isAuthenticated = false
    }

    // MARK: - Email/Password
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        print("Mock sign-in started...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // simulate 1s delay

        if email.lowercased() == "test@example.com" && password == "password" {
            isAuthenticated = true
            userName = "Test User"
            print("Signed in as Test User")
        } else {
            errorMessage = "Invalid credentials. Try test@example.com / password"
            print("Invalid login attempt")
        }
        isLoading = false
    }

    func signUp(email: String, password: String, username: String = "") async {
        isLoading = true
        errorMessage = nil
        print("Mock sign-up started...")
        try? await Task.sleep(nanoseconds: 1_000_000_000) // simulate 1s delay

        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            print("Sign-up failed — missing info")
        } else {
            isAuthenticated = true
            userName = username.isEmpty ? "New User" : username
            print("Signed up as \(userName ?? "User")")
        }
        isLoading = false
    }

    // MARK: - Mock Google Sign-In
    func signInWithGoogle() async {
        isLoading = true
        print("Simulating Google Sign-In...")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isAuthenticated = true
        userName = "Google User"
        isLoading = false
        print("Mock Google sign-in complete")
    }

    // MARK: - Mock Apple Sign-In
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        print("🍎 Simulating Apple Sign-In...")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isAuthenticated = true
        userName = "Apple User"
        isLoading = false
        print("Mock Apple sign-in complete")
    }
}
