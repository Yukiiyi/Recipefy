//
//  Scan.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import Foundation
import FirebaseFirestore

struct Scan: Identifiable, Codable {
  @DocumentID var id: String?
  let userId: String
  let imagePath: String
  var status: String            // "uploaded" | "processing" | "done" | "error"
  let createdAt: Date
}
