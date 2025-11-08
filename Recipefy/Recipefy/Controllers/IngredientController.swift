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
  
  private let geminiService = GeminiService()
  private let db = Firestore.firestore()
  
  func analyzeIngredients(imageData: Data, scanId: String) async {
    isAnalyzing = true
    currentIngredients = nil
    statusText = "Analyzing ingredients with AI..."
    
    do {
      guard let image = UIImage(data: imageData) else {
        throw IngredientError.invalidImage
      }
      
      let ingredients = try await geminiService.analyzeIngredients(image: image)
      // Don't set currentIngredients yet - wait until saved with IDs
      
      // Automatically save ingredients after analysis
      await saveIngredients(scanId: scanId, ingredients: ingredients)
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
      // Save each ingredient as a separate document in the scan's subcollection
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      for (index, ingredient) in ingredientsWithIds.enumerated() {
        let ingredientData: [String: Any] = [
          "name": ingredient.name,
          "amount": ingredient.amount,
          "category": ingredient.category.rawValue,
          "createdAt": Timestamp(date: Date())
        ]
        
        let docRef = try await ingredientsCollection.addDocument(data: ingredientData)
        ingredientsWithIds[index].id = docRef.documentID
      }
      
      // Only set currentIngredients after all IDs are assigned
      currentIngredients = ingredientsWithIds
      saveSuccess = true
    } catch {
      statusText = "Save error: \(error.localizedDescription)"
      saveSuccess = false
    }
  }
  
  func deleteIngredient(scanId: String, ingredient: Ingredient) async {
    guard let ingredientId = ingredient.id else {
      statusText = "Cannot delete: ingredient has no ID"
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
      statusText = "Delete error: \(error.localizedDescription)"
    }
  }
  
  func addIngredient(scanId: String, name: String, amount: String, category: IngredientCategory) async {
    do {
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      let ingredientData: [String: Any] = [
        "name": name,
        "amount": amount,
        "category": category.rawValue,
        "createdAt": Timestamp(date: Date())
      ]
      
      let docRef = try await ingredientsCollection.addDocument(data: ingredientData)
      
      // Create new ingredient with ID and add to top of list
      let newIngredient = Ingredient(id: docRef.documentID, name: name, amount: amount, category: category)
      if currentIngredients != nil {
        currentIngredients?.insert(newIngredient, at: 0)  // Add to top
      } else {
        currentIngredients = [newIngredient]
      }
    } catch {
      statusText = "Add error: \(error.localizedDescription)"
      print("Error adding ingredient: \(error)")
    }
  }
  
  func updateIngredient(scanId: String, ingredient: Ingredient, name: String, amount: String, category: IngredientCategory) async {
    guard let ingredientId = ingredient.id else {
      statusText = "Cannot update: ingredient has no ID"
      return
    }
    
    do {
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      let ingredientData: [String: Any] = [
        "name": name,
        "amount": amount,
        "category": category.rawValue,
        "createdAt": ingredient.id != nil ? Timestamp(date: Date()) : Timestamp(date: Date()) // Keep original if exists
      ]
      
      try await ingredientsCollection.document(ingredientId).setData(ingredientData, merge: true)
      
      // Update in local state
      if let index = currentIngredients?.firstIndex(where: { $0.id == ingredientId }) {
        currentIngredients?[index] = Ingredient(id: ingredientId, name: name, amount: amount, category: category)
      }
    } catch {
      statusText = "Update error: \(error.localizedDescription)"
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
