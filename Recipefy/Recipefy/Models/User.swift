//
//  User.swift
//  Recipefy
//
//  User model for Firebase Authentication and Firestore storage
//

import Foundation
import FirebaseFirestore

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String
    var email: String
    var displayName: String
    var photoURL: String?
    var authProvider: AuthProvider
    var createdAt: Date
    var updatedAt: Date
    
    enum AuthProvider: String, Codable {
        case email = "email"
        case apple = "apple"
        case google = "google"
    }
    
    init(
        uid: String,
        email: String,
        displayName: String,
        photoURL: String? = nil,
        authProvider: AuthProvider,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.authProvider = authProvider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

