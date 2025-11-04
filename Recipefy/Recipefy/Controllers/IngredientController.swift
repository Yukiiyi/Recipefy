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
      currentIngredients = ingredients
      isAnalyzing = false
      
      // Automatically save ingredients after analysis
      await saveIngredients(scanId: scanId)
    } catch {
      currentIngredients = nil
      statusText = "Error: \(error.localizedDescription)"
      isAnalyzing = false
    }
  }
  
  private func saveIngredients(scanId: String) async {
    guard let ingredients = currentIngredients else {
      return
    }
    
    do {
      // Save each ingredient as a separate document in the scan's subcollection
      let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
      
      for ingredient in ingredients {
        let ingredientData: [String: Any] = [
          "name": ingredient.name,
          "amount": ingredient.amount,
          "category": ingredient.category,
          "createdAt": Timestamp(date: Date())
        ]
        
        try await ingredientsCollection.addDocument(data: ingredientData)
      }
      
      saveSuccess = true
    } catch {
      statusText = "Save error: \(error.localizedDescription)"
      saveSuccess = false
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
