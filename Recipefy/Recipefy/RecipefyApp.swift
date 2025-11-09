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
  @StateObject private var authController = AuthController()

  var body: some Scene {
    WindowGroup {
      NavigationView {
        if authController.isAuthenticated {
          HomeView()
        } else {
          AuthView()
        }
      }
      .environmentObject(authController)
    }
  }
}
