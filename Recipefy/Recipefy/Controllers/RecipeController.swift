//
//  RecipeController.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/7/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit
import Combine

final class RecipeController: ObservableObject {
	@Published var statusText = "Idle"
  @Published var currentRecipe: Recipe?
	@Published var isRetrieving = false
	@Published var isSaving = false
	@Published var saveSuccess = false
    
  private let geminiService = GeminiService()
	private let db = Firestore.firestore()
	
	func getRecipe(ingredients: [Ingredient]) async {
		let ingredientsData = ingredients.map { $0.toDictionary() }
		isRetrieving = true
		currentRecipe = nil
		statusText = "Generating Recipes with AI..."
		
		do {
//			guard
			
			let recipe = try await geminiService.getRecipe(ingredients: ingredientsData)
			currentRecipe = recipe
			statusText = "Found recipe \(recipe.recipeID)!"
			isRetrieving = false
		} catch {
			currentRecipe = nil
			statusText = "Error: \(error.localizedDescription)"
			isRetrieving = false
		}
	}
	
	func saveRecipe() async throws {
		guard let recipe = currentRecipe else {
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
			let recipeData = recipe.toDictionary()
			let analysisData: [String: Any] = [
				"userId": userId,
				"recipe": recipeData,
				"analyzedAt": Timestamp(date: Date()),
				"type": "recipe_generation"
			]
			
			let docRef = try await db.collection("recipe").addDocument(data: analysisData)
			statusText = "Saved successfully! (ID: \(docRef.documentID))"
			saveSuccess = true
			isSaving = false
		}
	}
}


