//
//  FirebaseScanRepository.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import FirebaseFirestore

final class FirebaseScanRepository: ScanRepository {
  private let db = Firestore.firestore()

  func createScan(userId: String, imagePath: String) async throws -> String {
    let doc = db.collection(FirestorePaths.scans).document()
    let scan = Scan(
      id: doc.documentID,
      userId: userId,
      imagePath: imagePath,
      status: "uploaded",
      createdAt: Date()
    )
    try doc.setData(from: scan)
    return doc.documentID
  }
}
