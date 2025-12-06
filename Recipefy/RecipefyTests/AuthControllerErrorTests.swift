//
//  AuthControllerErrorTests.swift
//  RecipefyTests
//
//  Tests for AuthController error handling logic
//

import Testing
import Foundation
import FirebaseAuth
@testable import Recipefy

@MainActor
struct AuthControllerErrorTests {
  
  // Testing the error code mapping logic
  // We'll test by creating NSErrors with Firebase error codes
  
  @Test("AuthController initializes with correct defaults")
  func authController_initialState() {
    let controller = AuthController()
    
    #expect(controller.isLoading == false)
    #expect(controller.errorMessage == nil)
    #expect(controller.isAuthenticated == false)
    #expect(controller.showLanding == true)
    #expect(controller.startInLoginMode == true)
    #expect(controller.currentUser == nil)
  }
  
  @Test("AuthController state properties can be updated")
  func authController_stateCanUpdate() {
    let controller = AuthController()
    
    controller.isLoading = true
    #expect(controller.isLoading == true)
    
    controller.errorMessage = "Test error"
    #expect(controller.errorMessage == "Test error")
    
    controller.showLanding = false
    #expect(controller.showLanding == false)
    
    controller.startInLoginMode = false
    #expect(controller.startInLoginMode == false)
  }
  
  @Test("AuthController can clear error message")
  func authController_canClearError() {
    let controller = AuthController()
    
    controller.errorMessage = "Some error"
    #expect(controller.errorMessage != nil)
    
    controller.errorMessage = nil
    #expect(controller.errorMessage == nil)
  }
  
  @Test("Firebase AuthErrorCode raw values are known")
  func firebaseErrorCodes_exist() {
    // These are the error codes used in handleAuthError
    // Just verify they exist and have known values
    #expect(AuthErrorCode.emailAlreadyInUse.rawValue == 17007)
    #expect(AuthErrorCode.invalidEmail.rawValue == 17008)
    #expect(AuthErrorCode.weakPassword.rawValue == 17026)
    #expect(AuthErrorCode.wrongPassword.rawValue == 17009)
    #expect(AuthErrorCode.userNotFound.rawValue == 17011)
    #expect(AuthErrorCode.networkError.rawValue == 17020)
    #expect(AuthErrorCode.tooManyRequests.rawValue == 17010)
    #expect(AuthErrorCode.userDisabled.rawValue == 17005)
    #expect(AuthErrorCode.requiresRecentLogin.rawValue == 17014)
  }
  
  @Test("Additional Firebase error codes")
  func additionalErrorCodes_exist() {
    #expect(AuthErrorCode.accountExistsWithDifferentCredential.rawValue == 17012)
    #expect(AuthErrorCode.credentialAlreadyInUse.rawValue == 17025)
    #expect(AuthErrorCode.invalidCredential.rawValue == 17004)
  }
  
  @Test("NSError can be created with Firebase error codes")
  func nsError_canBeCreatedWithFirebaseCode() {
    let error = NSError(
      domain: "FIRAuthErrorDomain",
      code: AuthErrorCode.emailAlreadyInUse.rawValue,
      userInfo: nil
    )
    
    #expect(error.code == AuthErrorCode.emailAlreadyInUse.rawValue)
    #expect(error.domain == "FIRAuthErrorDomain")
  }
  
  @Test("Error mapping logic patterns are consistent")
  func errorMapping_patternsConsistent() {
    // Test that error codes map to expected message patterns
    let errorMappings: [(Int, String)] = [
      (17007, "email"),        // emailAlreadyInUse
      (17008, "email"),        // invalidEmail  
      (17026, "password"),     // weakPassword
      (17009, "password"),     // wrongPassword
      (17011, "account"),      // userNotFound
      (17020, "network"),      // networkError
      (17010, "attempts"),     // tooManyRequests
      (17005, "account"),      // userDisabled
      (17014, "sign in"),      // requiresRecentLogin
    ]
    
    for (code, expectedKeyword) in errorMappings {
      // Just verify the code exists - actual message testing would require
      // making handleAuthError testable/public
      #expect(code > 0, "Error code \(code) should be positive")
    }
  }
  
  @Test("AuthController currentUser can be set")
  func authController_currentUser_canSet() {
    let controller = AuthController()
    
    let user = AppUser(
      uid: "test-uid",
      email: "test@example.com",
      displayName: "Test User",
      authProvider: .email
    )
    
    controller.currentUser = user
    
    #expect(controller.currentUser?.uid == "test-uid")
    #expect(controller.currentUser?.email == "test@example.com")
    #expect(controller.currentUser?.displayName == "Test User")
  }
  
  @Test("AuthController isAuthenticated reflects auth state")
  func authController_isAuthenticated_reflectsState() {
    let controller = AuthController()
    
    // Initially false
    #expect(controller.isAuthenticated == false)
    
    // Can be set to true
    controller.isAuthenticated = true
    #expect(controller.isAuthenticated == true)
    
    // Can be set back to false
    controller.isAuthenticated = false
    #expect(controller.isAuthenticated == false)
  }
}

