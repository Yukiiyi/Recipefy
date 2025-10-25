//
//  StorageService.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import Foundation

protocol StorageService {
  func uploadScanImage(data: Data, uid: String, scanId: String) async throws -> String
}
