//
//  IngredientController.swift
//  Recipefy
//
//  Created by yuqi zou on 10/25/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit
import Combine

@MainActor
final class IngredientController: ObservableObject {
  @Published var statusText = "Idle"
  @Published var currentIngredients: [Ingredient]?
  @Published var isAnalyzing = false
  @Published var saveSuccess = false
  @Published var errorMessage: String?
  @Published var currentScanId: String?  // Track which scan these ingredients belong to
  
  private let geminiService: GeminiServiceProtocol
  private let firestoreService: FirestoreServiceProtocol
  
  init(geminiService: GeminiServiceProtocol, firestoreService: FirestoreServiceProtocol) {
    self.geminiService = geminiService
    self.firestoreService = firestoreService
  }
  
  // Note: createIngredientData() method removed - now handled by FirestoreService
  
  // MARK: - Public Methods
  
  func analyzeIngredients(imageData: Data, scanId: String) async {
    await analyzeMultipleImages(imageDataArray: [imageData], scanId: scanId)
  }
  
  func analyzeMultipleImages(imageDataArray: [Data], scanId: String) async {
    // Prevent duplicate analysis
    guard !isAnalyzing else { return }
    
    isAnalyzing = true
    currentIngredients = nil
    let imageCount = imageDataArray.count
    statusText = "Analyzing \(imageCount) \(imageCount == 1 ? "image" : "images")..."
    
    // Use Task to run the analysis - this survives view lifecycle changes
    Task { @MainActor in
      do {
        // Convert all image data to UIImage first
        let images: [UIImage] = try imageDataArray.compactMap { data in
          guard let image = UIImage(data: data) else {
            throw IngredientError.invalidImage
          }
          return image
        }
        
        // Analyze all images in parallel using TaskGroup
        let allIngredients: [Ingredient] = try await withThrowingTaskGroup(of: [Ingredient].self) { group in
          for image in images {
            group.addTask {
              try await self.geminiService.analyzeIngredients(image: image)
            }
          }
          
          var results: [Ingredient] = []
          for try await ingredients in group {
            results.append(contentsOf: ingredients)
          }
          return results
        }
        
        // Save all ingredients
        let ingredientCount = allIngredients.count
        statusText = "Saving \(ingredientCount) \(ingredientCount == 1 ? "ingredient" : "ingredients")..."
        await saveIngredients(scanId: scanId, ingredients: allIngredients)
        currentScanId = scanId
        isAnalyzing = false
      } catch {
        currentIngredients = nil
        statusText = "Error: \(error.localizedDescription)"
        isAnalyzing = false
      }
    }
  }
  
  private func saveIngredients(scanId: String, ingredients: [Ingredient]) async {
    do {
      let savedIngredients = try await firestoreService.saveIngredients(scanId: scanId, ingredients: ingredients)
      currentIngredients = savedIngredients
      saveSuccess = true
    } catch {
      statusText = "Save error: \(error.localizedDescription)"
      saveSuccess = false
    }
  }
  
  /// Loads ingredients from Firestore for a specific scan
  func loadIngredients(scanId: String) async {
    isAnalyzing = true
    statusText = "Loading ingredients..."
    
    do {
      let ingredients = try await firestoreService.loadIngredients(scanId: scanId)
      currentIngredients = ingredients
      currentScanId = scanId
      statusText = ingredients.isEmpty ? "No ingredients yet" : "Loaded \(ingredients.count) ingredients"
      isAnalyzing = false
      print("Loaded \(ingredients.count) ingredients from scan \(scanId)")
    } catch {
      currentIngredients = []
      statusText = "No ingredients yet"
      isAnalyzing = false
      print("Load ingredients error: \(error.localizedDescription)")
    }
  }
  
  func deleteIngredient(scanId: String, ingredient: Ingredient) async {
    guard let ingredientId = ingredient.id else {
      errorMessage = "Cannot delete: ingredient has no ID"
      return
    }
    
    do {
      try await firestoreService.deleteIngredient(scanId: scanId, ingredientId: ingredientId)
      currentIngredients?.removeAll { $0.id == ingredientId }
    } catch {
      errorMessage = "Failed to delete ingredient: \(error.localizedDescription)"
    }
  }
  
  func addIngredient(scanId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async {
    do {
      let newIngredient = try await firestoreService.addIngredient(scanId: scanId, name: name, quantity: quantity, unit: unit, category: category)
      
      if currentIngredients != nil {
        currentIngredients?.insert(newIngredient, at: 0)  // Add to top
      } else {
        currentIngredients = [newIngredient]
      }
    } catch {
      errorMessage = "Failed to add ingredient: \(error.localizedDescription)"
      print("Error adding ingredient: \(error)")
    }
  }
  
  func updateIngredient(scanId: String, ingredient: Ingredient, name: String, quantity: String, unit: String, category: IngredientCategory) async {
    guard let ingredientId = ingredient.id else {
      errorMessage = "Cannot update: ingredient has no ID"
      return
    }
    
    do {
      try await firestoreService.updateIngredient(scanId: scanId, ingredientId: ingredientId, name: name, quantity: quantity, unit: unit, category: category)
      
      // Update in local state
      if let index = currentIngredients?.firstIndex(where: { $0.id == ingredientId }) {
        currentIngredients?[index] = Ingredient(id: ingredientId, name: name, quantity: quantity, unit: unit, category: category)
      }
    } catch {
      errorMessage = "Failed to update ingredient: \(error.localizedDescription)"
      print("Error updating ingredient: \(error)")
    }
  }
}

enum IngredientError: LocalizedError {
  case invalidImage
  case noIngredients
  
  var errorDescription: String? {
    switch self {
    case .invalidImage:
      return "Invalid image data"
    case .noIngredients:
      return "No ingredients to save"
    }
  }
}
