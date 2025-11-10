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
  @Published var currentScanId: String?
  @Published var currentImageData: [Data]?

  private let storage: StorageService
  private let scans: ScanRepository

  init(storage: StorageService, scans: ScanRepository) {
    self.storage = storage
    self.scans = scans
  }

  func uploadAndCreateScan(imageData: Data) async {
    await uploadAndCreateScanWithMultipleImages(imageDataArray: [imageData])
  }
  
  func uploadAndCreateScanWithMultipleImages(imageDataArray: [Data]) async {
    guard let uid = Auth.auth().currentUser?.uid else {
      statusText = "No user (auth failed)"
      return
    }

    do {
      let scanId = UUID().uuidString
      var uploadedPaths: [String] = []
      
      // Upload each image
      for (index, imageData) in imageDataArray.enumerated() {
        statusText = "Uploading image \(index + 1) of \(imageDataArray.count)..."
        let compressed = (UIImage(data: imageData)?.jpegData(compressionQuality: 0.75)) ?? imageData
        
        // Generate unique filename for each image
        let imageFileName = index == 0 ? scanId : "\(scanId)_\(index)"
        let path = try await storage.uploadScanImage(data: compressed, uid: uid, scanId: imageFileName)
        uploadedPaths.append(path)
      }

      statusText = "Writing Firestore doc..."
      let id = try await scans.createScan(userId: uid, imagePaths: uploadedPaths)

      currentScanId = id
      currentImageData = imageDataArray
      statusText = "Upload complete (scanId: \(id), \(uploadedPaths.count) images)"
    } catch {
      statusText = "Error: \(error.localizedDescription)"
    }
  }
}
