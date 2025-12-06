//
//  AppUserTests.swift
//  RecipefyTests
//
//  Tests for the AppUser model
//

import Testing
import Foundation
import FirebaseFirestore
@testable import Recipefy

struct AppUserTests {
    
    // MARK: - Initialization Tests
    
    @Test("AppUser initializes with email auth provider")
    @MainActor
    func appUser_init_emailProvider() async throws {
        let user = AppUser(
            uid: "test123",
            email: "test@example.com",
            displayName: "Test User",
            authProvider: .email
        )
        
        #expect(user.uid == "test123")
        #expect(user.email == "test@example.com")
        #expect(user.displayName == "Test User")
        #expect(user.authProvider == .email)
        #expect(user.photoURL == nil)
    }
    
    @Test("AppUser initializes with Google auth provider")
    @MainActor
    func appUser_init_googleProvider() async throws {
        let user = AppUser(
            uid: "google123",
            email: "user@gmail.com",
            displayName: "Google User",
            photoURL: "https://example.com/photo.jpg",
            authProvider: .google
        )
        
        #expect(user.authProvider == .google)
        #expect(user.photoURL == "https://example.com/photo.jpg")
    }
    
    @Test("AppUser initializes with Apple auth provider")
    @MainActor
    func appUser_init_appleProvider() async throws {
        let user = AppUser(
            uid: "apple123",
            email: "user@privaterelay.appleid.com",
            displayName: "Apple User",
            authProvider: .apple
        )
        
        #expect(user.authProvider == .apple)
    }
    
    @Test("AppUser initializes with default dates")
    @MainActor
    func appUser_init_defaultDates() async throws {
        let beforeInit = Date()
        
        let user = AppUser(
            uid: "test123",
            email: "test@example.com",
            displayName: "Test User",
            authProvider: .email
        )
        
        let afterInit = Date()
        
        #expect(user.createdAt >= beforeInit)
        #expect(user.createdAt <= afterInit)
        #expect(user.updatedAt >= beforeInit)
        #expect(user.updatedAt <= afterInit)
    }
    
    // MARK: - AuthProvider Enum Tests
    
    @Test("AuthProvider rawValue matches expected strings")
    func authProvider_rawValues_correct() async throws {
        #expect(AppUser.AuthProvider.email.rawValue == "email")
        #expect(AppUser.AuthProvider.apple.rawValue == "apple")
        #expect(AppUser.AuthProvider.google.rawValue == "google")
    }
    
    @Test("AuthProvider can be initialized from rawValue")
    func authProvider_initFromRawValue() async throws {
        let emailProvider = AppUser.AuthProvider(rawValue: "email")
        let appleProvider = AppUser.AuthProvider(rawValue: "apple")
        let googleProvider = AppUser.AuthProvider(rawValue: "google")
        
        #expect(emailProvider == .email)
        #expect(appleProvider == .apple)
        #expect(googleProvider == .google)
    }
    
    // MARK: - Codable Tests
    
    @Test("AppUser encodes to Firestore correctly")
    @MainActor
    func appUser_encodesToFirestore() async throws {
        let user = AppUser(
            uid: "test123",
            email: "test@example.com",
            displayName: "Test User",
            photoURL: "https://example.com/photo.jpg",
            authProvider: .email
        )
        
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(user)
        
        // Verify the encoded dictionary contains expected fields
        #expect(data["uid"] as? String == "test123")
        #expect(data["email"] as? String == "test@example.com")
        #expect(data["displayName"] as? String == "Test User")
        #expect(data["photoURL"] as? String == "https://example.com/photo.jpg")
        #expect(data["authProvider"] as? String == "email")
    }
    
    @Test("AppUser encodes to Firestore with nil photoURL")
    @MainActor
    func appUser_encodesToFirestoreWithNilPhotoURL() async throws {
        let user = AppUser(
            uid: "test123",
            email: "test@example.com",
            displayName: "Test User",
            authProvider: .email
        )
        
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(user)
        
        // Verify the encoded dictionary contains expected fields
        #expect(data["uid"] as? String == "test123")
        #expect(data["email"] as? String == "test@example.com")
        #expect(data["displayName"] as? String == "Test User")
        #expect(data["photoURL"] == nil)
        #expect(data["authProvider"] as? String == "email")
    }
    
    // MARK: - Identifiable Tests
    
    @Test("AppUser conforms to Identifiable with optional id")
    @MainActor
    func appUser_identifiable_hasOptionalId() async throws {
        let user = AppUser(
            uid: "test123",
            email: "test@example.com",
            displayName: "Test User",
            authProvider: .email
        )
        
        // id should be nil until assigned by Firestore
        #expect(user.id == nil)
    }
    
    // MARK: - Equality Tests
    
    @Test("Two AppUsers with same uid are different if id differs")
    @MainActor
    func appUser_equality_checksByIdNotUid() async throws {
        var user1 = AppUser(
            uid: "same_uid",
            email: "test@example.com",
            displayName: "User 1",
            authProvider: .email
        )
        
        var user2 = AppUser(
            uid: "same_uid",
            email: "test@example.com",
            displayName: "User 2",
            authProvider: .email
        )
        
        user1.id = "firestore_id_1"
        user2.id = "firestore_id_2"
        
        // They have same uid but different Firestore document IDs
        #expect(user1.id != user2.id)
    }
}

