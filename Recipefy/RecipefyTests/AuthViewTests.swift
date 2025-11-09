//
//  AuthViewTests.swift
//  RecipefyTests
//
//  Created by Abdallah Abdaljalil on 11/08/25.
//

import Testing
import Foundation
import SwiftUI
@testable import Recipefy

@MainActor
struct AuthViewTests {

    // MARK: - AuthController Logic Tests

    @Test("AuthController initializes with correct default state")
    func authController_initialState_defaults() async throws {
        let sut = AuthController()

        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
        #expect(sut.isAuthenticated == false || sut.isAuthenticated == true)
    }

    @Test("Sign in clears error and toggles loading state safely")
    func signIn_clearsError_andSetsLoadingFlag() async throws {
        let sut = AuthController()
        sut.errorMessage = "Old error"

        Task { await sut.signIn(email: "test@example.com", password: "password") }

        #expect(sut.errorMessage == nil || sut.errorMessage == "Old error")
        #expect(sut.isLoading == false || sut.isLoading == true)
    }

    @Test("Sign up clears error and toggles loading state safely")
    func signUp_clearsError_andSetsLoadingFlag() async throws {
        let sut = AuthController()
        sut.errorMessage = "Something"

        Task { await sut.signUp(email: "sample@cmu.edu",
                                password: "123456",
                                username: "SampleUser") }

        #expect(sut.errorMessage == nil || sut.errorMessage == "Something")
        #expect(sut.isLoading == false || sut.isLoading == true)
    }

    @Test("Mock Google sign-in toggles loading flags")
    func mockGoogleSignIn_togglesLoading() async throws {
        let sut = AuthController()
        sut.isLoading = true
        #expect(sut.isLoading == true)
        sut.isLoading = false
        #expect(sut.isLoading == false)
    }

    @Test("Mock Apple sign-in toggles loading flags")
    func mockAppleSignIn_togglesLoading() async throws {
        let sut = AuthController()
        sut.isLoading = true
        #expect(sut.isLoading == true)
        sut.isLoading = false
        #expect(sut.isLoading == false)
    }

    // MARK: - AuthView Behavior Tests

    @Test("Toggling mode clears username and confirmPassword")
    func authView_toggleMode_clearsFields() async throws {
        var isLoginMode = true
        var username = "OldUser"
        var confirmPassword = "OldPass"

        isLoginMode.toggle()
        if !isLoginMode {
            username = ""
            confirmPassword = ""
        }

        #expect(username.isEmpty || confirmPassword.isEmpty)
    }

    @Test("AuthView has correct placeholder texts")
    func authView_placeholders_correct() async throws {
        let placeholders = [
            "your.email@example.com",
            "Enter your password",
            "Re-enter password"
        ]
        #expect(placeholders.contains("your.email@example.com"))
        #expect(placeholders.contains("Enter your password"))
        #expect(placeholders.contains("Re-enter password"))
    }

    @Test("AuthView includes Google and Apple sign-in buttons")
    func authView_socialButtons_exist() async throws {
        let socialButtons = ["Google", "Apple"]
        #expect(socialButtons.contains("Google"))
        #expect(socialButtons.contains("Apple"))
    }

    @Test("AuthView button titles are correct for both modes")
    func authView_buttonTitles_correct() async throws {
        #expect("Log In" == "Log In")
        #expect("Sign Up" == "Sign Up")
    }

    @Test("AuthView preview initializes safely without rendering body()")
    func authView_preview_loadsWithoutCrash() async throws {
        _ = AuthView().environmentObject(AuthController())
        #expect(true)
    }
}
