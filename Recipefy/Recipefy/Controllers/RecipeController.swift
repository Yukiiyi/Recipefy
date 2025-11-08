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

@MainActor
final class RecipeController: ObservableObject {
	@Published var statusText = "Idle"
  @Published var currentRecipes: [Recipe]?
	@Published var isRetrieving = false
	@Published var isSaving = false
	@Published var saveSuccess = false
    
  private let geminiService = GeminiService()
	private let db = Firestore.firestore()
	
	func getRecipe(ingredients: [Ingredient]) async {
		let ingredientsData = ingredients.map { $0.toDictionary() }
		
		let formattedIngredients = ingredientsData.compactMap { item in
					if let name = item["name"], let amount = item["amount"] {
					 return "\(amount) \(name)"
			 } else {
					 return nil
			 }
		}
		isRetrieving = true
		currentRecipes = nil
		statusText = "Generating Recipes with AI..."
		
		do {
//			guard
			
			let recipe = try await geminiService.getRecipe(ingredients: formattedIngredients)
			currentRecipes = recipe
			statusText = "Found \(recipe.count) recipes !"
			isRetrieving = false
		} catch {
			currentRecipes = nil
			statusText = "Error: \(error.localizedDescription)"
			isRetrieving = false
		}
	}
	
	func saveRecipe() async throws {
		guard let recipes = currentRecipes else {
			statusText = "No recipes to save"
			return
		}
		
//		guard let userId = Auth.auth().currentUser?.uid else {
//			statusText = "No authenticated user"
//			return
//		}
		
		isSaving = true
		statusText = "Saving to database..."
		
		for r in recipes {
//			saveSuccess = false
			
			do {
				let nutrition = ["carbs": r.carbs, "description": r.description, "fat": r.fat, "fiber": r.fiber, "protein": r.protein] as [String : Any]
				let analysisData: [String: Any] = [
	//				"userId": userId,
					"calories": r.calories,
					"cookMin": r.cookMin,
					"createdAt": Timestamp(date: Date()),
					"ingredients": r.ingredients,
					"nutrition": nutrition,
					"servings": r.servings,
					"steps": r.steps
				]
				
				let docRef = try await db.collection("recipe").addDocument(data: analysisData)
				statusText = "Saved successfully! (ID: \(docRef.documentID))"
//				saveSuccess = true
			}
		}
		saveSuccess = true
		isSaving = false
	}
}


