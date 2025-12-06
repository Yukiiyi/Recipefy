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
	@Published var favoriteRecipes: [Recipe]?
	@Published var isRetrieving = false
	@Published var isSaving = false
	@Published var saveSuccess = false
	@Published var lastGeneratedScanId: String?
	@Published var isLoadingMore = false
    
  private let geminiService: GeminiServiceProtocol
	private let firestoreService: FirestoreServiceProtocol
	private var lastFormattedIngredients: [String] = []
	
	init(geminiService: GeminiServiceProtocol, firestoreService: FirestoreServiceProtocol) {
		self.geminiService = geminiService
		self.firestoreService = firestoreService
	}
	
	func getRecipe(ingredients: [Ingredient], sourceScanId: String? = nil) async {
		let ingredientsData = ingredients.map { $0.toDictionary() }
		
		let formattedIngredients = ingredientsData.compactMap { item in
					if let name = item["name"], let quantity = item["quantity"], let unit = item["unit"] {
					 return "\(quantity) \(unit) \(name)"
			 } else {
					 return nil
			 }
		}
		lastFormattedIngredients = formattedIngredients
		
		isRetrieving = true
		isLoadingMore = false
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
			print(statusText)
			isRetrieving = false
		}
	}
	
	/// Saves recipes to Firestore under the current user's collection
	/// - Parameters:
	///   - recipes: Specific recipes to save. If nil, saves all currentRecipes.
	///   - sourceScanId: Optional scan ID that generated these recipes
	func saveRecipes(_ recipes: [Recipe]? = nil, sourceScanId: String? = nil) async {
		let recipesToSave = recipes ?? currentRecipes
		
		guard let recipesToSave, !recipesToSave.isEmpty else {
			statusText = "No recipes to save"
			return
		}
		
		guard let userId = Auth.auth().currentUser?.uid else {
			statusText = "No authenticated user"
			return
		}
		
		isSaving = true
		
		do {
			try await firestoreService.saveRecipes(userId: userId, recipes: recipesToSave, sourceScanId: sourceScanId)
			saveSuccess = true
			print("✅ Saved \(recipesToSave.count) recipes to Firestore")
		} catch {
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
			let result = try await firestoreService.loadRecipes(userId: userId)
			currentRecipes = result.recipes
			lastGeneratedScanId = result.scanId
			statusText = result.recipes.isEmpty ? "No recipes yet" : "Loaded \(result.recipes.count) recipes"
			isRetrieving = false
		} catch {
			currentRecipes = []
			statusText = "No recipes yet"
			isRetrieving = false
			print("❌ Load recipes error: \(error.localizedDescription)")
		}
	}

	func toggleFavorite(for recipeID: String) {
		// Flip in currentRecipes
		if let index = currentRecipes?.firstIndex(where: { $0.recipeID == recipeID }) {
			currentRecipes?[index].favorited.toggle()
		}
		
		// Flip in favoriteRecipes
		if let index = favoriteRecipes?.firstIndex(where: { $0.recipeID == recipeID }) {
			favoriteRecipes?[index].favorited.toggle()
		}
		
		// Figure out the new value
		let newValue =
			currentRecipes?.first(where: { $0.recipeID == recipeID })?.favorited ??
			favoriteRecipes?.first(where: { $0.recipeID == recipeID })?.favorited ??
			false
		
		// Persist to Firestore
		Task {
			do {
				try await firestoreService.updateRecipeFavorite(recipeId: recipeID, isFavorited: newValue)
			} catch {
					print("❌ Failed to update favorite: \(error.localizedDescription)")
			}
		}
	}
	
	func loadFavoriteRecipes() async {
		guard let userId = Auth.auth().currentUser?.uid else {
			statusText = "No authenticated user"
			return
		}
		
		isRetrieving = true
		statusText = "Loading favorites..."
		
		do {
			let recipes = try await firestoreService.loadFavoriteRecipes(userId: userId)
			favoriteRecipes = recipes
			statusText = recipes.isEmpty ? "No favorites yet" : "Loaded \(recipes.count) favorites"
		} catch {
			favoriteRecipes = []
			statusText = "Failed to load favorites"
			print("❌ Load favorites error: \(error.localizedDescription)")
		}
		
		isRetrieving = false
	}
	
	func loadMoreRecipesIfNeeded() async {
			// Don't re-enter while already loading, or if we have nothing to use
			guard !isRetrieving, !isLoadingMore, !lastFormattedIngredients.isEmpty else {
				return
			}
			
			isLoadingMore = true
			
			do {
				let moreRecipes = try await geminiService.getRecipe(ingredients: lastFormattedIngredients)
				
				if currentRecipes == nil {
					currentRecipes = moreRecipes
				} else {
					currentRecipes?.append(contentsOf: moreRecipes)
				}

				Task {
					await self.saveRecipes(moreRecipes, sourceScanId: self.lastGeneratedScanId)
				}
			} catch {
				print("❌ Failed to load more recipes: \(error.localizedDescription)")
			}
			
			isLoadingMore = false
		}
}

