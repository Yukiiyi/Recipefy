//
//  RecipefyApp.swift
//  Recipefy
//
//  Created by streak honey on 10/23/25.
//

import SwiftUI

@main
struct RecipefyApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  // Shared controllers for entire app
  @StateObject private var navigationState = NavigationState()
  @StateObject private var authController = AuthController()
  @StateObject private var scanController = ScanController(
    storage: FirebaseStorageService(),
    scans: FirebaseScanRepository()
  )
  @StateObject private var ingredientController = IngredientController(
    geminiService: GeminiService(),
    firestoreService: FirebaseFirestoreService()
  )
  @StateObject private var recipeController = RecipeController(
    geminiService: GeminiService(),
    firestoreService: FirebaseFirestoreService()
  )

  var body: some Scene {
    WindowGroup {
      if authController.showLanding {
        // Show landing page (initial load or after logout)
        LandingView(showLanding: $authController.showLanding)
          .environmentObject(authController)
      } else if authController.isAuthenticated {
        // Show main app after authentication
        NavigationBarView()
          .environmentObject(navigationState)
          .environmentObject(authController)
          .environmentObject(scanController)
          .environmentObject(ingredientController)
          .environmentObject(recipeController)
      } else {
        // Show authentication view
        NavigationView {
          AuthView()
        }
        .environmentObject(authController)
      }
    }
  }
}
