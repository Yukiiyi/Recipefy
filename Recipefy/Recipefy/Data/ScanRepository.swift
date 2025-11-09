//
//  ScanRepository.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import Foundation

protocol ScanRepository {
  func createScan(userId: String, imagePaths: [String]) async throws -> String
}
