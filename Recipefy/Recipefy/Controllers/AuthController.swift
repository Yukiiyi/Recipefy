//
//  AuthController.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/06/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@MainActor
final class AuthController: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    init() {
        isAuthenticated = Auth.auth().currentUser != nil
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.isAuthenticated = user != nil
            }
        }
    }

    // MARK: - Email/Password
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(email: String, password: String, username: String = "") async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            if !username.isEmpty {
                await createUserProfile(userId: result.user.uid, email: email, username: username)
            }
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func createUserProfile(userId: String, email: String, username: String) async {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "email": email,
            "userName": username,  // Match Firebase structure: camelCase userName
            "createdAt": Timestamp(),
            "profilePhoto": ""     // Initialize empty, can be updated later
        ]
        do {
            try await db.collection("users").document(userId).setData(data)
            print("User profile created: \(userId) with userName: \(username)")
        } catch {
            print("Profile create error: \(error.localizedDescription)")
        }
    }

    // Helper to create user profile if it doesn't exist (for social sign-in)
    private func createUserProfileIfNeeded(userId: String, email: String) async {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)
        do {
            let doc = try await docRef.getDocument()
            if !doc.exists {
                let data: [String: Any] = [
                    "email": email,
                    "userName": "",
                    "createdAt": Timestamp(),
                    "profilePhoto": ""
                ]
                try await docRef.setData(data)
                print("User profile created for social sign-in: \(userId)")
            }
        } catch {
            print("Error checking/creating profile: \(error.localizedDescription)")
        }
    }

    // MARK: - Google
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        #if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Google Sign-In not configured"
            isLoading = false
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        guard let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = await scene.windows.first?.rootViewController else {
            errorMessage = "No root VC"
            isLoading = false
            return
        }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: root)
            guard let idToken = result.user.idToken?.tokenString else { throw NSError(domain: "Auth", code: -1) }
            let cred = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: cred)
            await createUserProfileIfNeeded(userId: authResult.user.uid, email: authResult.user.email ?? "")
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        #else
        errorMessage = "Install GoogleSignIn package to enable Google auth."
        #endif
        isLoading = false
    }

    // MARK: - Apple
    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        switch result {
        case .success(let auth):
            guard let cred = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = cred.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "No Apple token"
                isLoading = false
                return
            }
            let providerCred = OAuthProvider.credential(withProviderID: "apple.com", idToken: idToken, rawNonce: nil)
            do {
                let authResult = try await Auth.auth().signIn(with: providerCred)
                await createUserProfileIfNeeded(userId: authResult.user.uid, email: authResult.user.email ?? "")
                isAuthenticated = true
            } catch {
                errorMessage = error.localizedDescription
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
