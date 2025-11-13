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
  @StateObject private var ingredientController = IngredientController()
  @StateObject private var recipeController = RecipeController()

  var body: some Scene {
    WindowGroup {
      if authController.isAuthenticated {
        NavigationBarView()
          .environmentObject(navigationState)
          .environmentObject(authController)
          .environmentObject(scanController)
          .environmentObject(ingredientController)
          .environmentObject(recipeController)
      } else {
        NavigationView {
          AuthView()
        }
        .environmentObject(authController)
      }
    }
  }
}
