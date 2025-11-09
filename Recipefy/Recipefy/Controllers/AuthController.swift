//
//  AuthController.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/06/25.
//

import FirebaseStorage
import FirebaseCore
import Foundation

final class FirebaseStorageService: StorageService {
    private let bucket: Storage

    init() {
        // Ensure Firebase is configured before accessing Storage
        if FirebaseApp.app() == nil {
            print("FirebaseApp not found — configuring now.")
            FirebaseApp.configure()
        } else {
            print("FirebaseApp already configured.")
        }

        // Safe initialization
        self.bucket = Storage.storage()
    }

    func uploadScanImage(data: Data, uid: String, scanId: String) async throws -> String {
        let path = "images/scans/\(uid)/\(scanId).jpg"
        let ref = bucket.reference(withPath: path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        print("Uploading image to Firebase path: \(path)")
        _ = try await ref.putDataAsync(data, metadata: metadata)
        print("Upload complete")

        return path
    }
}
