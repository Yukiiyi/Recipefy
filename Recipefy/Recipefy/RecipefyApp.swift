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

  var body: some Scene {
    WindowGroup {
        let storage = FirebaseStorageService()
        let scans = FirebaseScanRepository()
        let controller = ScanController(storage: storage, scans: scans)
      NavigationView {
        ScanView(controller: controller)
      }
    }
  }
}
