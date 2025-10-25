//
//  FireStorePaths.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

enum FirestorePaths {
  static let scans = "scans"
  static func scan(_ id: String) -> String { "scans/\(id)" }
}
