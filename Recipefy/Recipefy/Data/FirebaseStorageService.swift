//
//  FirebaseStorageService.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import FirebaseStorage
import Foundation

final class FirebaseStorageService: StorageService {
  private let bucket = Storage.storage()
  func uploadScanImage(data: Data, uid: String, scanId: String) async throws -> String {
    let path = "images/scans/\(uid)/\(scanId).jpg"
    let ref = bucket.reference(withPath: path)
    let metadata = StorageMetadata(); metadata.contentType = "image/jpeg"
    _ = try await ref.putDataAsync(data, metadata: metadata)
    return path
  }
}
