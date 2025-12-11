//
//  RecipeControllerTests.swift
//  RecipefyTests
//
//  Additional tests for RecipeController with mocked services
//

import Testing
import Foundation
import UIKit
@testable import Recipefy

@MainActor
struct RecipeControllerTests {
  
  // MARK: - Mock Services
  
  class MockGeminiService: GeminiServiceProtocol {
    var getRecipeCallCount = 0
    var lastIngredientsReceived: [String] = []
    var mockRecipes: [Recipe] = []
    var shouldThrowError = false
    
    func analyzeIngredients(image: UIImage) async throws -> [Ingredient] {
      return []
    }
    
    func getRecipe(ingredients: [String]) async throws -> [Recipe] {
      getRecipeCallCount += 1
      lastIngredientsReceived = ingredients
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
    var lastSavedRecipes: [Recipe] = []
    var lastSavedUserId: String = ""
    var lastSavedScanId: String? = nil
    
    var mockRecipes: [Recipe] = []
    var mockFavoriteRecipes: [Recipe] = []
    var mockScanId: String? = nil
    var shouldThrowError = false
    
    // Ingredient operations (not used)
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
      lastSavedRecipes = recipes
      lastSavedUserId = userId
      lastSavedScanId = sourceScanId
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
      return mockFavoriteRecipes
    }
    
    func updateRecipeFavorite(recipeId: String, isFavorited: Bool) async throws {
      updateRecipeFavoriteCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
    }
    
    func loadDietaryPreferences(userId: String) async throws -> DietaryPreferences? { return nil }
    func saveDietaryPreferences(userId: String, preferences: DietaryPreferences) async throws {}
  }
  
  // MARK: - Helper
  
  func createSUT() -> (controller: RecipeController, gemini: MockGeminiService, firestore: MockFirestoreService) {
    let gemini = MockGeminiService()
    let firestore = MockFirestoreService()
    let controller = RecipeController(geminiService: gemini, firestoreService: firestore)
    return (controller, gemini, firestore)
  }
  
  func createMockRecipe(id: String = "test-id", title: String = "Test Recipe", favorited: Bool = false) -> Recipe {
    return Recipe(
      recipeID: id,
      title: title,
      description: "Test description",
      ingredients: ["1 cup flour", "2 eggs"],
      steps: ["Mix", "Bake"],
      calories: 200,
      servings: 2,
      cookMin: 30,
      protein: 10,
      carbs: 25,
      fat: 8,
      fiber: 2,
      sugar: 5,
      favorited: favorited
    )
  }
  
  // MARK: - State Management Tests
  
  @Test("RecipeController statusText can be updated")
  func recipeController_statusText_canUpdate() async throws {
    let (sut, _, _) = createSUT()
    
    sut.statusText = "Loading..."
    #expect(sut.statusText == "Loading...")
    
    sut.statusText = "Complete"
    #expect(sut.statusText == "Complete")
  }
  
  @Test("RecipeController isRetrieving can be toggled")
  func recipeController_isRetrieving_canToggle() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.isRetrieving == false)
    
    sut.isRetrieving = true
    #expect(sut.isRetrieving == true)
  }
  
  @Test("RecipeController isSaving can be toggled")
  func recipeController_isSaving_canToggle() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.isSaving == false)
    
    sut.isSaving = true
    #expect(sut.isSaving == true)
  }
  
  @Test("RecipeController isLoadingMore can be toggled")
  func recipeController_isLoadingMore_canToggle() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.isLoadingMore == false)
    
    sut.isLoadingMore = true
    #expect(sut.isLoadingMore == true)
  }
  
  @Test("RecipeController lastGeneratedScanId can be set")
  func recipeController_lastGeneratedScanId_canSet() async throws {
    let (sut, _, _) = createSUT()
    
    sut.lastGeneratedScanId = "scan-123"
    #expect(sut.lastGeneratedScanId == "scan-123")
  }
  
  // MARK: - Toggle Favorite Tests
  
  @Test("toggleFavorite flips favorited in currentRecipes")
  func toggleFavorite_flipsInCurrentRecipes() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = [createMockRecipe(id: "r1", favorited: false)]
    
    sut.toggleFavorite(for: "r1")
    #expect(sut.currentRecipes?.first?.favorited == true)
    
    sut.toggleFavorite(for: "r1")
    #expect(sut.currentRecipes?.first?.favorited == false)
  }
  
  @Test("toggleFavorite removes unfavorited recipe from favoriteRecipes")
  func toggleFavorite_flipsInFavoriteRecipes() async throws {
    let (sut, _, _) = createSUT()
    
    sut.favoriteRecipes = [createMockRecipe(id: "fav1", favorited: true)]
    
    sut.toggleFavorite(for: "fav1")
    // When unfavoriting, the recipe is removed from favoriteRecipes
    #expect(sut.favoriteRecipes?.isEmpty == true)
  }
  
  @Test("toggleFavorite updates both currentRecipes and favoriteRecipes if present")
  func toggleFavorite_updatesBothLists() async throws {
    let (sut, _, _) = createSUT()
    
    let recipe = createMockRecipe(id: "shared-id", favorited: false)
    sut.currentRecipes = [recipe]
    sut.favoriteRecipes = [recipe]
    
    sut.toggleFavorite(for: "shared-id")
    
    #expect(sut.currentRecipes?.first?.favorited == true)
    #expect(sut.favoriteRecipes?.first?.favorited == true)
  }
  
  @Test("toggleFavorite does nothing for non-existent recipe")
  func toggleFavorite_nonExistentRecipe_noChange() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = [createMockRecipe(id: "existing", favorited: false)]
    
    sut.toggleFavorite(for: "non-existent")
    
    // Original recipe should be unchanged
    #expect(sut.currentRecipes?.first?.favorited == false)
  }
  
  // MARK: - Recipes Storage Tests
  
  @Test("currentRecipes can store multiple recipes")
  func currentRecipes_canStoreMultiple() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = [
      createMockRecipe(id: "1", title: "Recipe 1"),
      createMockRecipe(id: "2", title: "Recipe 2"),
      createMockRecipe(id: "3", title: "Recipe 3")
    ]
    
    #expect(sut.currentRecipes?.count == 3)
    #expect(sut.currentRecipes?[0].title == "Recipe 1")
    #expect(sut.currentRecipes?[1].title == "Recipe 2")
    #expect(sut.currentRecipes?[2].title == "Recipe 3")
  }
  
  @Test("favoriteRecipes can store multiple recipes")
  func favoriteRecipes_canStoreMultiple() async throws {
    let (sut, _, _) = createSUT()
    
    sut.favoriteRecipes = [
      createMockRecipe(id: "f1", favorited: true),
      createMockRecipe(id: "f2", favorited: true)
    ]
    
    #expect(sut.favoriteRecipes?.count == 2)
  }
  
  @Test("recipes can be cleared")
  func recipes_canBeCleared() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = [createMockRecipe()]
    sut.favoriteRecipes = [createMockRecipe(favorited: true)]
    
    sut.currentRecipes = nil
    sut.favoriteRecipes = nil
    
    #expect(sut.currentRecipes == nil)
    #expect(sut.favoriteRecipes == nil)
  }
  
  // MARK: - saveRecipes Tests
  
  @Test("saveRecipes with no recipes sets status message")
  func saveRecipes_noRecipes_setsMessage() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = nil
    await sut.saveRecipes()
    
    #expect(sut.statusText == "No recipes to save")
    #expect(sut.isSaving == false)
    #expect(sut.saveSuccess == false)
  }
  
  @Test("saveRecipes with empty array sets status message")
  func saveRecipes_emptyArray_setsMessage() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentRecipes = []
    await sut.saveRecipes()
    
    #expect(sut.statusText == "No recipes to save")
  }
  
  // MARK: - Nutrition Model Tests
  
  @Test("Nutrition model stores all values")
  func nutrition_storesAllValues() async throws {
    let nutrition = Nutrition(
      protein: 25,
      carbs: 50,
      fat: 15,
      fiber: 8,
      sugar: 10,
      description: "High protein meal"
    )
    
    #expect(nutrition.protein == 25)
    #expect(nutrition.carbs == 50)
    #expect(nutrition.fat == 15)
    #expect(nutrition.fiber == 8)
    #expect(nutrition.sugar == 10)
    #expect(nutrition.description == "High protein meal")
  }
  
  @Test("Nutrition with nil sugar")
  func nutrition_nilSugar() async throws {
    let nutrition = Nutrition(
      protein: 20,
      carbs: 30,
      fat: 10,
      fiber: 5,
      sugar: nil,
      description: "No sugar info"
    )
    
    #expect(nutrition.sugar == nil)
  }
  
  // MARK: - RawRecipe Tests
  
  @Test("RawRecipe can be created with all fields")
  func rawRecipe_allFields() async throws {
    let nutrition = Nutrition(protein: 20, carbs: 30, fat: 10, fiber: 5, sugar: 8, description: "Healthy")
    let raw = RawRecipe(
      title: "Test Dish",
      ingredients: ["ingredient 1", "ingredient 2"],
      steps: ["step 1", "step 2", "step 3"],
      cookMin: 45,
      calories: 350,
      servings: 4,
      nutrition: nutrition,
      favorited: true
    )
    
    #expect(raw.title == "Test Dish")
    #expect(raw.ingredients.count == 2)
    #expect(raw.steps.count == 3)
    #expect(raw.cookMin == 45)
    #expect(raw.calories == 350)
    #expect(raw.servings == 4)
    #expect(raw.favorited == true)
  }
  
  @Test("RawRecipe with nil favorited")
  func rawRecipe_nilFavorited() async throws {
    let nutrition = Nutrition(protein: 20, carbs: 30, fat: 10, fiber: 5, sugar: 8, description: "Desc")
    let raw = RawRecipe(
      title: "Dish",
      ingredients: [],
      steps: [],
      cookMin: 30,
      calories: 200,
      servings: 2,
      nutrition: nutrition,
      favorited: nil
    )
    
    #expect(raw.favorited == nil)
  }
  
  // MARK: - canGenerateMore Tests
  
  @Test("canGenerateMore is false initially")
  func canGenerateMore_initiallyFalse() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.canGenerateMore == false)
  }
  
  @Test("canGenerateMore is true after getRecipe with ingredients")
  func canGenerateMore_trueAfterGetRecipe() async throws {
    let (sut, gemini, _) = createSUT()
    gemini.mockRecipes = [createMockRecipe()]
    
    let ingredients = [
      Ingredient(id: "1", name: "Chicken", quantity: "500", unit: "gram", category: .proteins)
    ]
    
    await sut.getRecipe(ingredients: ingredients)
    
    #expect(sut.canGenerateMore == true)
  }
  
  @Test("canGenerateMore remains false after loadRecipes from DB")
  func canGenerateMore_falseAfterLoadRecipes() async throws {
    let (sut, _, firestore) = createSUT()
    firestore.mockRecipes = [createMockRecipe()]
    
    // Loading from DB doesn't set ingredients, so canGenerateMore should stay false
    await sut.loadRecipes()
    
    #expect(sut.canGenerateMore == false)
  }
  
  // MARK: - loadMoreRecipesIfNeeded Tests
  
  @Test("loadMoreRecipesIfNeeded does nothing when canGenerateMore is false")
  func loadMoreRecipesIfNeeded_noIngredientsDoesNothing() async throws {
    let (sut, gemini, _) = createSUT()
    gemini.mockRecipes = [createMockRecipe()]
    
    await sut.loadMoreRecipesIfNeeded()
    
    // Should not call gemini since no ingredients available
    #expect(gemini.getRecipeCallCount == 0)
    #expect(sut.currentRecipes == nil)
  }
  
  @Test("loadMoreRecipesIfNeeded generates more recipes when ingredients available")
  func loadMoreRecipesIfNeeded_withIngredientsGeneratesMore() async throws {
    let (sut, gemini, _) = createSUT()
    let recipe1 = createMockRecipe(id: "r1", title: "Recipe 1")
    let recipe2 = createMockRecipe(id: "r2", title: "Recipe 2")
    gemini.mockRecipes = [recipe1]
    
    let ingredients = [
      Ingredient(id: "1", name: "Chicken", quantity: "500", unit: "gram", category: .proteins)
    ]
    
    // First call to getRecipe sets up ingredients
    await sut.getRecipe(ingredients: ingredients)
    #expect(gemini.getRecipeCallCount == 1)
    #expect(sut.currentRecipes?.count == 1)
    
    // Now loadMoreRecipesIfNeeded should work
    gemini.mockRecipes = [recipe2]
    await sut.loadMoreRecipesIfNeeded()
    
    #expect(gemini.getRecipeCallCount == 2)
    #expect(sut.currentRecipes?.count == 2)
  }
}

