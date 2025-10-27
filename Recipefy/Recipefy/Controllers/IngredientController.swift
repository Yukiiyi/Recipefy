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
  
  func saveIngredients() async {
    guard let ingredients = currentIngredients else {
      statusText = "No ingredients to save"
      return
    }
    
    guard let userId = Auth.auth().currentUser?.uid else {
      statusText = "No authenticated user"
      return
    }
    
    isSaving = true
    statusText = "Saving to database..."
    
    do {
      let ingredientsData = ingredients.map { $0.toDictionary() }
      let analysisData: [String: Any] = [
        "userId": userId,
        "ingredients": ingredientsData,
        "ingredientCount": ingredients.count,
        "analyzedAt": Timestamp(date: Date()),
        "type": "ingredient_scan"
      ]
      
      let docRef = try await db.collection("ingredient_analyses").addDocument(data: analysisData)
      statusText = "Saved successfully! (ID: \(docRef.documentID))"
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
