//
//  RecipeTests.swift
//  RecipefyTests
//
//  Created by Jonass Oh on 11/8/25.
//

import Testing
import Foundation
import UIKit
@testable import Recipefy

@MainActor
struct RecipeTests {
  
  // MARK: - Mock Services
  
  class MockGeminiService: GeminiServiceProtocol {
    var getRecipeCallCount = 0
    var mockRecipes: [Recipe] = []
    var shouldThrowError = false
    
    func analyzeIngredients(image: UIImage) async throws -> [Ingredient] {
      return []
    }
    
    func getRecipe(ingredients: [String]) async throws -> [Recipe] {
      getRecipeCallCount += 1
      if shouldThrowError {
        throw GeminiError.noResponse
      }
      return mockRecipes
    }
  }
  
  class MockFirestoreService: FirestoreServiceProtocol {
    var saveRecipesCallCount = 0
    var loadRecipesCallCount = 0
    var loadFavoriteRecipesCallCount = 0
    var updateRecipeFavoriteCallCount = 0
    
    var mockRecipes: [Recipe] = []
    var mockScanId: String? = nil
    var shouldThrowError = false
    
    // Ingredient operations (not used in RecipeController tests)
    func saveIngredients(scanId: String, ingredients: [Ingredient]) async throws -> [Ingredient] { return [] }
    func loadIngredients(scanId: String) async throws -> [Ingredient] { return [] }
    func deleteIngredient(scanId: String, ingredientId: String) async throws {}
    func addIngredient(scanId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws -> Ingredient {
      return Ingredient(id: "mock", name: name, quantity: quantity, unit: unit, category: category)
    }
    func updateIngredient(scanId: String, ingredientId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws {}
    
    // Recipe operations
    func saveRecipes(userId: String, recipes: [Recipe], sourceScanId: String?) async throws {
      saveRecipesCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
    }
    
    func loadRecipes(userId: String) async throws -> (recipes: [Recipe], scanId: String?) {
      loadRecipesCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
      return (mockRecipes, mockScanId)
    }
    
    func loadFavoriteRecipes(userId: String) async throws -> [Recipe] {
      loadFavoriteRecipesCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
      return mockRecipes.filter { $0.favorited }
    }
    
    func updateRecipeFavorite(recipeId: String, isFavorited: Bool) async throws {
      updateRecipeFavoriteCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
    }
    
    func loadDietaryPreferences(userId: String) async throws -> DietaryPreferences? { return nil }
    func saveDietaryPreferences(userId: String, preferences: DietaryPreferences) async throws {}
  }
  
  // MARK: - Helper to create controller with mocks
  
  func createSUT() -> (controller: RecipeController, gemini: MockGeminiService, firestore: MockFirestoreService) {
    let gemini = MockGeminiService()
    let firestore = MockFirestoreService()
    let controller = RecipeController(geminiService: gemini, firestoreService: firestore)
    return (controller, gemini, firestore)
  }
  
  // MARK: - RecipeController Initial State
  
  @Test
  func initialState_defaults() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.statusText == "Idle")
    #expect(sut.currentRecipes == nil)
    #expect(sut.favoriteRecipes == nil)
    #expect(sut.isRetrieving == false)
    #expect(sut.isSaving == false)
    #expect(sut.saveSuccess == false)
    #expect(sut.lastGeneratedScanId == nil)
    #expect(sut.isLoadingMore == false)
  }
  
  @Test
  func saveRecipes_whenNoCurrentRecipes_setsMessageAndDoesNotToggleSaving() async throws {
    let (sut, _, _) = createSUT()
    
    // Precondition
    #expect(sut.currentRecipes == nil)
    
    // Act
    await sut.saveRecipes()
    
    // Assert
    #expect(sut.statusText == "No recipes to save")
    #expect(sut.isSaving == false)
    #expect(sut.saveSuccess == false)
  }
  
  // MARK: - Toggle Favorite Tests
  
  @Test
  func toggleFavorite_updatesCurrentRecipes() async throws {
    let (sut, _, _) = createSUT()
    
    // Set up a recipe
    sut.currentRecipes = [
      Recipe(
        recipeID: "recipe-1",
        title: "Test Recipe",
        description: "Test",
        ingredients: ["1 cup flour"],
        steps: ["Mix"],
        calories: 200,
        servings: 2,
        cookMin: 30,
        protein: 10,
        carbs: 20,
        fat: 5,
        fiber: 2,
        sugar: 3,
        favorited: false
      )
    ]
    
    // Toggle favorite
    sut.toggleFavorite(for: "recipe-1")
    
    // Check it was toggled
    #expect(sut.currentRecipes?.first?.favorited == true)
    
    // Toggle again
    sut.toggleFavorite(for: "recipe-1")
    #expect(sut.currentRecipes?.first?.favorited == false)
  }
  
  @Test
  func toggleFavorite_updatesFavoriteRecipes() async throws {
    let (sut, _, _) = createSUT()
    
    // Set up a favorited recipe
    sut.favoriteRecipes = [
      Recipe(
        recipeID: "fav-1",
        title: "Favorite Recipe",
        description: "Delicious",
        ingredients: ["2 eggs"],
        steps: ["Cook"],
        calories: 150,
        servings: 1,
        cookMin: 10,
        protein: 12,
        carbs: 1,
        fat: 10,
        fiber: 0,
        sugar: 0,
        favorited: true
      )
    ]
    
    // Toggle favorite off
    sut.toggleFavorite(for: "fav-1")
    
    #expect(sut.favoriteRecipes?.first?.favorited == false)
  }
  
  // MARK: - State Management Tests
  
  @Test
  func canStoreRecipes() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = [
      Recipe(
        recipeID: "r1",
        title: "Recipe 1",
        description: "Desc 1",
        ingredients: [],
        steps: [],
        calories: 100,
        servings: 1,
        cookMin: 15,
        protein: 5,
        carbs: 10,
        fat: 2,
        fiber: 1,
        sugar: 1,
        favorited: false
      )
    ]
    
    #expect(sut.currentRecipes?.count == 1)
    #expect(sut.currentRecipes?.first?.title == "Recipe 1")
  }
  
  // MARK: - Models (pure mapping tests, no Firebase/Gemini needed)
  
  @Test
  func recipe_initFromRawRecipe_mapsAllFields() async throws {
    // Given
    let nutrition = Nutrition(protein: 25, carbs: 50, fat: 10, fiber: 6, sugar: 8, description: "Balanced meal")
    let raw = RawRecipe(
      title: "Test Bowl",
      ingredients: ["1 cup rice", "200g chicken", "1 tbsp oil"],
      steps: ["Cook rice", "Sear chicken", "Combine"],
      cookMin: 30,
      calories: 600,
      servings: 2,
      nutrition: nutrition
    )
    
    // When
    let mapped = Recipe(from: raw)
    
    // Then
    #expect(mapped.title == "Test Bowl")
    #expect(mapped.description == "Balanced meal")
    #expect(mapped.ingredients.count == 3)
    #expect(mapped.steps.count == 3)
    #expect(mapped.cookMin == 30)
    #expect(mapped.calories == 600)
    #expect(mapped.servings == 2)
    #expect(mapped.protein == 25)
    #expect(mapped.carbs == 50)
    #expect(mapped.fat == 10)
    #expect(mapped.fiber == 6)
    #expect(mapped.sugar == 8)
    
    // UUID should be generated and non-empty
    #expect(!mapped.recipeID.isEmpty)
  }
  
  @Test
  func recipe_initFromRawRecipe_handlesNilSugar() async throws {
    let nutrition = Nutrition(protein: 10, carbs: 20, fat: 5, fiber: 3, sugar: nil, description: "No sugar info")
    let raw = RawRecipe(
      title: "Sugar Free",
      ingredients: ["ingredient"],
      steps: ["step"],
      cookMin: 15,
      calories: 200,
      servings: 1,
      nutrition: nutrition
    )
    
    let mapped = Recipe(from: raw)
    
    #expect(mapped.sugar == 0)  // Defaults to 0 when nil
  }
  
  @Test
  func recipe_initFromRawRecipe_handlesNilFavorited() async throws {
    let nutrition = Nutrition(protein: 10, carbs: 20, fat: 5, fiber: 3, sugar: 5, description: "Test")
    let raw = RawRecipe(
      title: "Not Favorited",
      ingredients: ["ingredient"],
      steps: ["step"],
      cookMin: 15,
      calories: 200,
      servings: 1,
      nutrition: nutrition,
      favorited: nil
    )
    
    let mapped = Recipe(from: raw)
    
    #expect(mapped.favorited == false)  // Defaults to false when nil
  }
  
  @Test
  func ingredient_dictionary_roundTrip() async throws {
    // Given
    let ingredient = Ingredient(id: nil, name: "Tomato", quantity: "2", unit: "cup", category: .vegetables)
    
    // When
    let dict = ingredient.toDictionary()
    let roundTripped = Ingredient.from(dictionary: dict)
    
    // Then
    #expect(dict["name"] == "Tomato")
    #expect(dict["quantity"] == "2")
    #expect(dict["unit"] == "cup")
    #expect(dict["category"] == "Vegetables")
    #expect(roundTripped?.name == "Tomato")
    #expect(roundTripped?.quantity == "2")
    #expect(roundTripped?.unit == "cup")
    #expect(roundTripped?.amount == "2 cup")
    #expect(roundTripped?.category == .vegetables)
  }
  
  // MARK: - GeminiError Tests
  
  @Test
  func geminiError_noResponse_description() async throws {
    let error = GeminiError.noResponse
    #expect(error.errorDescription == "No response from Gemini AI")
  }
  
  @Test
  func geminiError_parsingError_description() async throws {
    let error = GeminiError.parsingError
    #expect(error.errorDescription == "Failed to parse AI response")
  }
  
  @Test
  func geminiError_invalidImage_description() async throws {
    let error = GeminiError.invalidImage
    #expect(error.errorDescription == "Invalid image data")
  }
}
