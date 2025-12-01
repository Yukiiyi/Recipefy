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
	@Published var favoritedRecipes: [Recipe]?
	@Published var isRetrieving = false
	@Published var isSaving = false
	@Published var saveSuccess = false
	@Published var lastGeneratedScanId: String?
    
  private let geminiService = GeminiService()
	private let db = Firestore.firestore()
	
	func getRecipe(ingredients: [Ingredient], sourceScanId: String? = nil) async {
		let ingredientsData = ingredients.map { $0.toDictionary() }
		
		let formattedIngredients = ingredientsData.compactMap { item in
					if let name = item["name"], let quantity = item["quantity"], let unit = item["unit"] {
					 return "\(quantity) \(unit) \(name)"
			 } else {
					 return nil
			 }
		}
		isRetrieving = true
		currentRecipes = nil
		statusText = "Generating Recipes with AI..."
		
		do {
			let recipe = try await geminiService.getRecipe(ingredients: formattedIngredients)
			currentRecipes = recipe
			lastGeneratedScanId = sourceScanId
			isRetrieving = false
			statusText = "Found \(recipe.count) recipes!"
			
			// Automatically save recipes to Firestore (silently, don't change statusText)
			Task {
				await self.saveRecipes(sourceScanId: sourceScanId)
			}
		} catch {
			currentRecipes = nil
			statusText = "Error: \(error.localizedDescription)"
			isRetrieving = false
		}
	}
	
	/// Saves recipes to Firestore under the current user's collection
	/// - Parameter sourceScanId: Optional scan ID that generated these recipes
	func saveRecipes(sourceScanId: String? = nil) async {
		guard let recipes = currentRecipes else {
			statusText = "No recipes to save"
			return
		}
		
		guard let userId = Auth.auth().currentUser?.uid else {
			statusText = "No authenticated user"
			return
		}
		
		isSaving = true
		
		do {
			// Save each recipe to top-level recipes collection
			for recipe in recipes {
				let recipeData: [String: Any] = [
					"title": recipe.title,
					"description": recipe.description,
					"ingredients": recipe.ingredients,
					"steps": recipe.steps,
					"calories": recipe.calories,
					"servings": recipe.servings,
					"cookMin": recipe.cookMin,
					"protein": recipe.protein,
					"carbs": recipe.carbs,
					"fat": recipe.fat,
					"fiber": recipe.fiber,
					"sugar": recipe.sugar,
					"createdBy": userId,
					"sourceScanId": sourceScanId ?? "",
					"favorited": recipe.favorited,
					"createdAt": Timestamp(date: Date())
				]
				
				let _ = try await db.collection("recipes")
					.addDocument(data: recipeData)
			}
			
			// Don't overwrite statusText - keep the "Found X recipes!" message
			saveSuccess = true
			print("✅ Saved \(recipes.count) recipes to Firestore")
		} catch {
			// Only update status on error
			statusText = "Save error: \(error.localizedDescription)"
			saveSuccess = false
			print("❌ Failed to save recipes: \(error)")
		}
		
		isSaving = false
	}
	
	/// Loads recipes from the most recent scan
	/// Ensures recipes from different scans are never mixed together
	func loadRecipes() async {
		guard let userId = Auth.auth().currentUser?.uid else {
			statusText = "No authenticated user"
			return
		}
		
		isRetrieving = true
		statusText = "Loading your recipes..."
		
		do {
			// Step 1: Get the most recent recipe to find the latest scan
			let recentSnapshot = try await db.collection("recipes")
				.whereField("createdBy", isEqualTo: userId)
				.order(by: "createdAt", descending: true)
				.limit(to: 1)
				.getDocuments()
			
			// If no recipes exist, return empty
			guard let mostRecentDoc = recentSnapshot.documents.first,
						let mostRecentScanId = mostRecentDoc.data()["sourceScanId"] as? String,
						!mostRecentScanId.isEmpty else {
				currentRecipes = []
				statusText = "No recipes yet"
				isRetrieving = false
				return
			}
			
			// Step 2: Get all recipes from that scan
			let snapshot = try await db.collection("recipes")
				.whereField("createdBy", isEqualTo: userId)
				.whereField("sourceScanId", isEqualTo: mostRecentScanId)
				.order(by: "createdAt", descending: false)  // Keep generation order
				.getDocuments()
			
			// Map Firestore documents to Recipe objects
			let recipes = snapshot.documents.compactMap { doc -> Recipe? in
				let data = doc.data()
				
				// Extract all fields from Firestore document
				guard let title = data["title"] as? String,
							let description = data["description"] as? String,
							let ingredients = data["ingredients"] as? [String],
							let steps = data["steps"] as? [String],
							let calories = data["calories"] as? Int,
							let servings = data["servings"] as? Int,
							let cookMin = data["cookMin"] as? Int,
							let protein = data["protein"] as? Int,
							let carbs = data["carbs"] as? Int,
							let fat = data["fat"] as? Int,
							let fiber = data["fiber"] as? Int,
							let sugar = data["sugar"] as? Int
				else {
					return nil
				}
				
				let favorited = data["favorited"] as? Bool ?? false
				
				// Create Recipe object with document ID as recipeID
				return Recipe(
					recipeID: doc.documentID,
					title: title,
					description: description,
					ingredients: ingredients,
					steps: steps,
					calories: calories,
					servings: servings,
					cookMin: cookMin,
					protein: protein,
					carbs: carbs,
					fat: fat,
					fiber: fiber,
					sugar: sugar,
					favorited: favorited
				)
			}
			
			currentRecipes = recipes
			lastGeneratedScanId = mostRecentScanId
			statusText = recipes.isEmpty ? "No recipes yet" : "Loaded \(recipes.count) recipes"
			isRetrieving = false
		} catch {
			currentRecipes = []  // Empty array instead of nil
			statusText = "No recipes yet"
			isRetrieving = false
			print("❌ Load recipes error: \(error.localizedDescription)")
		}
	}
	
	func favoriteRecipe(recipeID: String, favorited: Bool) async {
		guard let userId = Auth.auth().currentUser?.uid else {
			print("No authenticated user")
			return
		}
		
		// Update local state immediately for responsive UI
		if let index = currentRecipes?.firstIndex(where: { $0.recipeID == recipeID }) {
			currentRecipes?[index].favorited = favorited
		}
		
		do {
			let recipeRef = db.collection("recipes").document(recipeID)
			try await recipeRef.updateData(["favorited": favorited])
			print("✅ Recipe \(recipeID) favorited status updated to \(favorited)")
		} catch {
			// Revert on error
			if let index = currentRecipes?.firstIndex(where: { $0.recipeID == recipeID }) {
				currentRecipes?[index].favorited = !favorited
			}
			print("❌ Failed to update favorite status: \(error.localizedDescription)")
		}
	}
	
	func getFavoriteRecipes() async {
		guard let userId = Auth.auth().currentUser?.uid else {
			print("No authenticated user")
			return
		}

		isRetrieving = true
		statusText = "Loading favorites..."

		do {
			let snapshot = try await db.collection("recipes")
				.whereField("favorited", isEqualTo: true)
				.whereField("createdBy", isEqualTo: userId)
//				.order(by: "createdAt", descending: true)
				.getDocuments()

			let recipes = snapshot.documents.compactMap { doc -> Recipe? in
				let data = doc.data()

				guard let title = data["title"] as? String,
							let description = data["description"] as? String,
							let ingredients = data["ingredients"] as? [String],
							let steps = data["steps"] as? [String],
							let calories = data["calories"] as? Int,
							let servings = data["servings"] as? Int,
							let cookMin = data["cookMin"] as? Int,
							let protein = data["protein"] as? Int,
							let carbs = data["carbs"] as? Int,
							let fat = data["fat"] as? Int,
							let fiber = data["fiber"] as? Int,
							let sugar = data["sugar"] as? Int
				else { return nil }

				let favorited = data["favorited"] as? Bool ?? false

				return Recipe(
					recipeID: doc.documentID,
					title: title,
					description: description,
					ingredients: ingredients,
					steps: steps,
					calories: calories,
					servings: servings,
					cookMin: cookMin,
					protein: protein,
					carbs: carbs,
					fat: fat,
					fiber: fiber,
					sugar: sugar,
					favorited: favorited
				)
			}

			self.favoritedRecipes = recipes
			statusText = recipes.isEmpty ? "No favorites yet" : "Loaded \(recipes.count) favorites"
			isRetrieving = false

		} catch {
			favoritedRecipes = []
			statusText = "Failed to load favorites"
			isRetrieving = false
			print("❌ Favorite load error:", error.localizedDescription)
		}
	}
}


