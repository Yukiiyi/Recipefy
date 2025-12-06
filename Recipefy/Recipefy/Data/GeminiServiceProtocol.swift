//
//  GeminiServiceProtocol.swift
//  Recipefy
//
//  Protocol for AI service to enable dependency injection and testing
//

import Foundation
import UIKit

protocol GeminiServiceProtocol {
  func analyzeIngredients(image: UIImage) async throws -> [Ingredient]
  func getRecipe(ingredients: [String]) async throws -> [Recipe]
}

