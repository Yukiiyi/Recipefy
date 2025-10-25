//
//  AppDelegate.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    if Auth.auth().currentUser == nil {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Firebase anonymous sign-in error:", error)
          } else if let user = result?.user {
              print("Signed in as:", user.uid)
          }
        }
      }

    return true
  }
}


