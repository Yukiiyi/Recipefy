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
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthController: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var showLanding = false  // Start hidden - let auth check decide
    @Published var startInLoginMode = true
    @Published var currentUser: AppUser?
    @Published var isCheckingAuth = true  // Track initial auth check
    
    // MARK: - Private Properties
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let user = user, !user.isAnonymous {
                    // User is signed in (not anonymous)
                    self.isAuthenticated = true
                    self.showLanding = false
                    await self.fetchUserProfile(uid: user.uid)
                } else {
                    // User is signed out or anonymous - show landing
                    self.isAuthenticated = false
                    self.showLanding = true
                    self.currentUser = nil
                }
                
                // Auth check complete
                self.isCheckingAuth = false
            }
        }
    }
    
    // MARK: - Email/Password Authentication
    
    func signIn(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("✅ Signed in successfully: \(result.user.uid)")
            showLanding = false
            // Auth state listener will handle the rest
        } catch {
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String, username: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = result.user
            
            // Update display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            try await changeRequest.commitChanges()
            
            // Create user profile in Firestore
            let appUser = AppUser(
                uid: user.uid,
                email: email,
                displayName: username,
                authProvider: .email
            )
            try await saveUserProfile(appUser)
            
            print("✅ Account created successfully: \(user.uid)")
            showLanding = false
            // Auth state listener will handle the rest
        } catch {
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle() async {
        errorMessage = nil
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Google Sign-In configuration error"
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to get root view controller"
            isLoading = false
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token from Google"
                isLoading = false
                return
            }
            
            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            let user = authResult.user
            
            // Check if this is a new user
            let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
            if isNewUser {
                let appUser = AppUser(
                    uid: user.uid,
                    email: user.email ?? "",
                    displayName: user.displayName ?? result.user.profile?.name ?? "User",
                    photoURL: user.photoURL?.absoluteString ?? result.user.profile?.imageURL(withDimension: 200)?.absoluteString,
                    authProvider: .google
                )
                try await saveUserProfile(appUser)
            }
            
            print("✅ Google Sign-In successful: \(user.uid)")
            showLanding = false
            // Auth state listener will handle the rest
            
        } catch {
            if (error as NSError).code == GIDSignInError.canceled.rawValue {
                print("User cancelled Google Sign-In")
            } else {
                handleAuthError(error)
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Apple Sign-In
    
    /// Prepares the Apple Sign-In request with a nonce
    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        errorMessage = nil
        isLoading = true
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Invalid Apple credential"
                isLoading = false
                return
            }
            
            guard let nonce = currentNonce else {
                errorMessage = "Invalid state: Nonce not found"
                isLoading = false
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                errorMessage = "Unable to get Apple ID token"
                isLoading = false
                return
            }
            
            // Create Firebase credential
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            do {
                let authResult = try await Auth.auth().signIn(with: credential)
                let user = authResult.user
                
                // Check if this is a new user
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                if isNewUser {
                    // Apple only provides name on first sign-in
                    let displayName = [
                        appleIDCredential.fullName?.givenName,
                        appleIDCredential.fullName?.familyName
                    ].compactMap { $0 }.joined(separator: " ")
                    
                    let appUser = AppUser(
                        uid: user.uid,
                        email: appleIDCredential.email ?? user.email ?? "",
                        displayName: displayName.isEmpty ? "Apple User" : displayName,
                        authProvider: .apple
                    )
                    try await saveUserProfile(appUser)
                }
                
                print("✅ Apple Sign-In successful: \(user.uid)")
                showLanding = false
                // Auth state listener will handle the rest
                
            } catch {
                handleAuthError(error)
            }
            
        case .failure(let error):
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                print("User cancelled Apple Sign-In")
            } else {
                errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Password Reset
    
    func sendPasswordReset(to email: String) async -> Bool {
        errorMessage = nil
        isLoading = true
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("✅ Password reset email sent to: \(email)")
            isLoading = false
            return true
        } catch {
            handleAuthError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Update Profile
    
    func updateEmail(to newEmail: String) async -> Bool {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user signed in"
            return false
        }
        
        do {
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
            print("✅ Verification email sent for email update")
            return true
        } catch {
            handleAuthError(error)
            return false
        }
    }
    
    func updateDisplayName(to newName: String) async -> Bool {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user signed in"
            return false
        }
        
        do {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newName
            try await changeRequest.commitChanges()
            
            // Update Firestore
            try await db.collection("users").document(user.uid).updateData([
                "displayName": newName,
                "updatedAt": FieldValue.serverTimestamp()
            ])
            
            // Update local user
            currentUser?.displayName = newName
            
            print("✅ Display name updated to: \(newName)")
            return true
        } catch {
            handleAuthError(error)
            return false
        }
    }
    
    func updatePassword(currentPassword: String, newPassword: String) async -> Bool {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            errorMessage = "No user signed in or email not available"
            return false
        }
        
        do {
            // Re-authenticate first
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            try await user.reauthenticate(with: credential)
            
            // Update password
            try await user.updatePassword(to: newPassword)
            print("✅ Password updated successfully")
            return true
        } catch {
            handleAuthError(error)
            return false
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            isAuthenticated = false
            showLanding = true
            currentUser = nil
            errorMessage = nil
            isCheckingAuth = false  // Reset auth check state
            
            print("✅ User signed out")
        } catch {
            errorMessage = "Failed to sign out: \(error.localizedDescription)"
            print("❌ Sign out error: \(error)")
        }
    }
    
    // MARK: - Firestore User Profile
    
    private func saveUserProfile(_ user: AppUser) async throws {
        try db.collection("users").document(user.uid).setData(from: user)
        currentUser = user
        print("✅ User profile saved to Firestore")
    }
    
    private func fetchUserProfile(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            if document.exists {
                currentUser = try document.data(as: AppUser.self)
                print("✅ User profile loaded from Firestore")
            } else {
                // User exists in Auth but not in Firestore (edge case)
                // Create a basic profile from Auth data
                if let firebaseUser = Auth.auth().currentUser {
                    let appUser = AppUser(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        displayName: firebaseUser.displayName ?? "User",
                        photoURL: firebaseUser.photoURL?.absoluteString,
                        authProvider: .email // Default, might not be accurate
                    )
                    try await saveUserProfile(appUser)
                }
            }
        } catch {
            print("❌ Error fetching user profile: \(error)")
        }
    }
    
    // MARK: - Error Handling
    
    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = "This email is already registered. Try logging in instead."
        case AuthErrorCode.invalidEmail.rawValue:
            errorMessage = "Please enter a valid email address."
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = "Password must be at least 6 characters."
        case AuthErrorCode.wrongPassword.rawValue:
            errorMessage = "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            errorMessage = "No account found with this email."
        case AuthErrorCode.networkError.rawValue:
            errorMessage = "Network error. Please check your connection."
        case AuthErrorCode.tooManyRequests.rawValue:
            errorMessage = "Too many attempts. Please try again later."
        case AuthErrorCode.userDisabled.rawValue:
            errorMessage = "This account has been disabled."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            errorMessage = "Please sign in again to complete this action."
        case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
            errorMessage = "An account already exists with this email using a different sign-in method. Try signing in with email/password or the original provider."
        case AuthErrorCode.credentialAlreadyInUse.rawValue:
            errorMessage = "This credential is already associated with a different account."
        case AuthErrorCode.invalidCredential.rawValue:
            errorMessage = "Invalid credentials. Please try again."
        default:
            errorMessage = error.localizedDescription
        }
        
        print("❌ Auth error: \(error)")
    }
}
