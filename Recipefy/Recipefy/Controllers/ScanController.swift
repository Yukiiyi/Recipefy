//
//  ScanController.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import Foundation
import FirebaseAuth
import Combine
import UIKit

@MainActor
final class ScanController: ObservableObject {
  @Published var statusText = "Idle"
  @Published var lastScanId: String?

  private let storage: StorageService
  private let scans: ScanRepository

  init(storage: StorageService, scans: ScanRepository) {
    self.storage = storage
    self.scans = scans
  }

  func uploadAndCreateScan(imageData: Data) async {
    guard let uid = Auth.auth().currentUser?.uid else {
      statusText = "No user (auth failed)"
      return
    }

    do {
      statusText = "Uploading image..."
      let scanId = UUID().uuidString
      let compressed = (UIImage(data: imageData)?.jpegData(compressionQuality: 0.75)) ?? imageData
      let path = try await storage.uploadScanImage(data: compressed, uid: uid, scanId: scanId)

      statusText = "Writing Firestore doc..."
      let id = try await scans.createScan(userId: uid, imagePath: path)

      lastScanId = id
      statusText = "Upload complete (scanId: \(id))"
    } catch {
      statusText = "Error: \(error.localizedDescription)"
    }
  }
}
