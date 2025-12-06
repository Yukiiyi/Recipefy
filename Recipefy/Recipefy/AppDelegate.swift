//
//  AppDelegate.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Pre-warm Firestore connection to avoid cold start delays later
        // This establishes the connection in the background
        Task {
            let db = Firestore.firestore()
            _ = try? await db.collection("_warmup").document("ping").getDocument()
        }
        
        return true
    }
    
    // Handle Google Sign-In URL callback
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
