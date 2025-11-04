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
  @Published var isSaving = false
  @Published var saveSuccess = false
  
  private let geminiService = GeminiService()
  private let db = Firestore.firestore()
  
  func analyzeIngredients(imageData: Data) async {
    isAnalyzing = true
    currentIngredients = nil
    statusText = "Analyzing ingredients with AI..."
    
    do {
      guard let image = UIImage(data: imageData) else {
        throw IngredientError.invalidImage
      }
      
      let ingredients = try await geminiService.analyzeIngredients(image: image)
      currentIngredients = ingredients
      statusText = "Found \(ingredients.count) ingredients!"
      isAnalyzing = false
    } catch {
      currentIngredients = nil
      statusText = "Error: \(error.localizedDescription)"
      isAnalyzing = false
    }
  }
  
  func saveIngredients(scanId: String) async {
    guard let ingredients = currentIngredients else {
      statusText = "No ingredients to save"
      return
    }
    
    isSaving = true
    statusText = "Saving to database..."
    
    do {
      // Save each ingredient as a separate document in the scan's subcollection
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      var savedCount = 0
      for ingredient in ingredients {
        let ingredientData: [String: Any] = [
          "name": ingredient.name,
          "amount": ingredient.amount,
          "category": ingredient.category,
          "createdAt": Timestamp(date: Date())
        ]
        
        try await ingredientsCollection.addDocument(data: ingredientData)
        savedCount += 1
      }
      
      statusText = "Saved \(savedCount) ingredients successfully!"
      saveSuccess = true
      isSaving = false
    } catch {
      statusText = "Save error: \(error.localizedDescription)"
      saveSuccess = false
      isSaving = false
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
