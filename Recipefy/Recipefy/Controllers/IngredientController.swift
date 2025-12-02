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
  
  private let geminiService = GeminiService()
  private let db = Firestore.firestore()
  
  // MARK: - Helper Methods
  
  /// Creates Firestore-compatible ingredient data dictionary
  private func createIngredientData(
    name: String,
    quantity: String,
    unit: String,
    category: IngredientCategory,
    includeTimestamp: Bool = true
  ) -> [String: Any] {
    var data: [String: Any] = [
      "name": name,
      "quantity": quantity,
      "unit": unit,
      "category": category.rawValue
    ]
    if includeTimestamp {
      data["createdAt"] = Timestamp(date: Date())
    }
    return data
  }
  
  // MARK: - Public Methods
  
  func analyzeIngredients(imageData: Data, scanId: String) async {
    await analyzeMultipleImages(imageDataArray: [imageData], scanId: scanId)
  }
  
  func analyzeMultipleImages(imageDataArray: [Data], scanId: String) async {
    isAnalyzing = true
    currentIngredients = nil
    let imageCount = imageDataArray.count
    statusText = "Analyzing \(imageCount) \(imageCount == 1 ? "image" : "images")..."
    
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
  
  private func saveIngredients(scanId: String, ingredients: [Ingredient]) async {
    var ingredientsWithIds = ingredients
    
    do {
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      let batch = db.batch()
      
      // Create document references and add to batch
      for (index, ingredient) in ingredientsWithIds.enumerated() {
        // Generate document reference with auto-ID before batch commit
        let docRef = ingredientsCollection.document()
        ingredientsWithIds[index].id = docRef.documentID
        
        let ingredientData = createIngredientData(
          name: ingredient.name,
          quantity: ingredient.quantity,
          unit: ingredient.unit,
          category: ingredient.category
        )
        
        batch.setData(ingredientData, forDocument: docRef)
      }
      
      // Single network call to save all ingredients
      try await batch.commit()
      
      currentIngredients = ingredientsWithIds
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
      // Fetch all ingredients for this scan
      let snapshot = try await db.collection("scans")
        .document(scanId)
        .collection("ingredients")
        .getDocuments()
      
      // Map Firestore documents to Ingredient objects
      let ingredients = snapshot.documents.compactMap { doc -> Ingredient? in
        let data = doc.data()
        
        guard let name = data["name"] as? String,
              let quantity = data["quantity"] as? String,
              let unit = data["unit"] as? String,
              let categoryString = data["category"] as? String
        else {
          return nil
        }
        
        let category = IngredientCategory.from(string: categoryString)
        return Ingredient(id: doc.documentID, name: name, quantity: quantity, unit: unit, category: category)
      }
      
      currentIngredients = ingredients
      currentScanId = scanId  // Track which scan these belong to
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
      // Delete from Firestore
      try await db.collection("scans")
        .document(scanId)
        .collection("ingredients")
        .document(ingredientId)
        .delete()
      
      // Remove from local state
      currentIngredients?.removeAll { $0.id == ingredientId }
    } catch {
      errorMessage = "Failed to delete ingredient: \(error.localizedDescription)"
    }
  }
  
  func addIngredient(scanId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async {
    do {
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      let ingredientData = createIngredientData(name: name, quantity: quantity, unit: unit, category: category)
      let docRef = try await ingredientsCollection.addDocument(data: ingredientData)
      
      // Create new ingredient with ID and add to top of list
      let newIngredient = Ingredient(id: docRef.documentID, name: name, quantity: quantity, unit: unit, category: category)
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
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      // Don't update createdAt - it should remain the original timestamp
      let ingredientData = createIngredientData(name: name, quantity: quantity, unit: unit, category: category, includeTimestamp: false)
      try await ingredientsCollection.document(ingredientId).setData(ingredientData, merge: true)
      
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
