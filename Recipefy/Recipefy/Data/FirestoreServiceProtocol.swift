//
//  FirestoreServiceProtocol.swift
//  Recipefy
//
//  Protocol for Firestore database operations to enable dependency injection and testing
//

import Foundation
import FirebaseFirestore

protocol FirestoreServiceProtocol {
  // Ingredient operations
  func saveIngredients(scanId: String, ingredients: [Ingredient]) async throws -> [Ingredient]
  func loadIngredients(scanId: String) async throws -> [Ingredient]
  func deleteIngredient(scanId: String, ingredientId: String) async throws
  func addIngredient(scanId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws -> Ingredient
  func updateIngredient(scanId: String, ingredientId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws
  
  // Recipe operations
  func saveRecipes(userId: String, recipes: [Recipe], sourceScanId: String?) async throws
  func loadRecipes(userId: String) async throws -> (recipes: [Recipe], scanId: String?)
  func loadFavoriteRecipes(userId: String) async throws -> [Recipe]
  func updateRecipeFavorite(recipeId: String, isFavorited: Bool) async throws
  
  // Dietary preferences operations
  func loadDietaryPreferences(userId: String) async throws -> DietaryPreferences?
  func saveDietaryPreferences(userId: String, preferences: DietaryPreferences) async throws
}

