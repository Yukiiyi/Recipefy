//
//  IngredientControllerTests.swift
//  RecipefyTests
//
//  Created by streak honey on 11/10/25.
//

import Testing
import Foundation
import UIKit
@testable import Recipefy

@MainActor
struct IngredientControllerTests {
  
  // MARK: - Mock Services
  
  class MockGeminiService: GeminiServiceProtocol {
    var analyzeIngredientsCallCount = 0
    var mockIngredients: [Ingredient] = []
    var shouldThrowError = false
    
    func analyzeIngredients(image: UIImage) async throws -> [Ingredient] {
      analyzeIngredientsCallCount += 1
      if shouldThrowError {
        throw IngredientError.invalidImage
      }
      return mockIngredients
    }
    
    func getRecipe(ingredients: [String]) async throws -> [Recipe] {
      return []
    }
  }
  
  class MockFirestoreService: FirestoreServiceProtocol {
    var saveIngredientsCallCount = 0
    var loadIngredientsCallCount = 0
    var deleteIngredientCallCount = 0
    var addIngredientCallCount = 0
    var updateIngredientCallCount = 0
    
    var mockIngredients: [Ingredient] = []
    var shouldThrowError = false
    
    func saveIngredients(scanId: String, ingredients: [Ingredient]) async throws -> [Ingredient] {
      saveIngredientsCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
      // Return ingredients with IDs assigned
      return ingredients.enumerated().map { index, ing in
        Ingredient(id: "mock-id-\(index)", name: ing.name, quantity: ing.quantity, unit: ing.unit, category: ing.category)
      }
    }
    
    func loadIngredients(scanId: String) async throws -> [Ingredient] {
      loadIngredientsCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
      return mockIngredients
    }
    
    func deleteIngredient(scanId: String, ingredientId: String) async throws {
      deleteIngredientCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
    }
    
    func addIngredient(scanId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws -> Ingredient {
      addIngredientCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
      return Ingredient(id: "new-mock-id", name: name, quantity: quantity, unit: unit, category: category)
    }
    
    func updateIngredient(scanId: String, ingredientId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws {
      updateIngredientCallCount += 1
      if shouldThrowError { throw NSError(domain: "test", code: 1) }
    }
    
    // Recipe operations (not used in IngredientController tests)
    func saveRecipes(userId: String, recipes: [Recipe], sourceScanId: String?) async throws {}
    func loadRecipes(userId: String) async throws -> (recipes: [Recipe], scanId: String?) { return ([], nil) }
    func loadFavoriteRecipes(userId: String) async throws -> [Recipe] { return [] }
    func updateRecipeFavorite(recipeId: String, isFavorited: Bool) async throws {}
    func loadDietaryPreferences(userId: String) async throws -> DietaryPreferences? { return nil }
    func saveDietaryPreferences(userId: String, preferences: DietaryPreferences) async throws {}
  }
  
  // MARK: - Helper to create controller with mocks
  
  func createSUT() -> (controller: IngredientController, gemini: MockGeminiService, firestore: MockFirestoreService) {
    let gemini = MockGeminiService()
    let firestore = MockFirestoreService()
    let controller = IngredientController(geminiService: gemini, firestoreService: firestore)
    return (controller, gemini, firestore)
  }
  
  // MARK: - Initialization Tests
  
  @Test("IngredientController initializes with correct default state")
  func ingredientController_initialState_defaults() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.statusText == "Idle")
    #expect(sut.currentIngredients == nil)
    #expect(sut.isAnalyzing == false)
    #expect(sut.saveSuccess == false)
    #expect(sut.errorMessage == nil)
    #expect(sut.currentScanId == nil)
  }
  
  // MARK: - State Management Tests
  
  @Test("IngredientController statusText can be updated")
  func ingredientController_statusText_canUpdate() async throws {
    let (sut, _, _) = createSUT()
    
    sut.statusText = "Analyzing..."
    #expect(sut.statusText == "Analyzing...")
    
    sut.statusText = "Complete"
    #expect(sut.statusText == "Complete")
  }
  
  @Test("IngredientController isAnalyzing flag toggles")
  func ingredientController_isAnalyzing_toggles() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.isAnalyzing == false)
    
    sut.isAnalyzing = true
    #expect(sut.isAnalyzing == true)
    
    sut.isAnalyzing = false
    #expect(sut.isAnalyzing == false)
  }
  
  @Test("IngredientController saveSuccess flag toggles")
  func ingredientController_saveSuccess_toggles() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.saveSuccess == false)
    
    sut.saveSuccess = true
    #expect(sut.saveSuccess == true)
  }
  
  @Test("IngredientController errorMessage can be set and cleared")
  func ingredientController_errorMessage_canSetAndClear() async throws {
    let (sut, _, _) = createSUT()
    
    #expect(sut.errorMessage == nil)
    
    sut.errorMessage = "Test error"
    #expect(sut.errorMessage == "Test error")
    
    sut.errorMessage = nil
    #expect(sut.errorMessage == nil)
  }
  
  @Test("IngredientController currentScanId can be set")
  func ingredientController_currentScanId_canSet() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentScanId = "scan-123"
    #expect(sut.currentScanId == "scan-123")
  }
  
  // MARK: - Ingredients List Tests
  
  @Test("IngredientController can store ingredients list")
  func ingredientController_canStoreIngredients() async throws {
    let (sut, _, _) = createSUT()
    
    let ingredients = [
      Ingredient(id: "1", name: "Chicken", quantity: "500", unit: "gram", category: .proteins),
      Ingredient(id: "2", name: "Rice", quantity: "2", unit: "cup", category: .grains)
    ]
    
    sut.currentIngredients = ingredients
    
    #expect(sut.currentIngredients?.count == 2)
    #expect(sut.currentIngredients?[0].name == "Chicken")
    #expect(sut.currentIngredients?[1].name == "Rice")
  }
  
  @Test("IngredientController handles empty ingredients list")
  func ingredientController_handlesEmptyList() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentIngredients = []
    
    #expect(sut.currentIngredients?.isEmpty == true)
    #expect(sut.currentIngredients?.count == 0)
  }
  
  @Test("IngredientController can clear ingredients")
  func ingredientController_canClearIngredients() async throws {
    let (sut, _, _) = createSUT()
    
    sut.currentIngredients = [
      Ingredient(id: "1", name: "Tomato", quantity: "3", unit: "whole", category: .vegetables)
    ]
    
    #expect(sut.currentIngredients?.count == 1)
    
    sut.currentIngredients = nil
    #expect(sut.currentIngredients == nil)
  }
  
  // MARK: - Load Ingredients Tests (with mocks)
  
  @Test("loadIngredients calls firestore service")
  func ingredientController_loadIngredients_callsFirestore() async throws {
    let (sut, _, firestore) = createSUT()
    firestore.mockIngredients = [
      Ingredient(id: "1", name: "Carrot", quantity: "3", unit: "whole", category: .vegetables)
    ]
    
    await sut.loadIngredients(scanId: "test-scan")
    
    #expect(firestore.loadIngredientsCallCount == 1)
    #expect(sut.currentIngredients?.count == 1)
    #expect(sut.currentIngredients?.first?.name == "Carrot")
    #expect(sut.currentScanId == "test-scan")
    #expect(sut.isAnalyzing == false)
  }
  
  @Test("loadIngredients updates status text for empty results")
  func ingredientController_loadIngredients_emptyResults() async throws {
    let (sut, _, firestore) = createSUT()
    firestore.mockIngredients = []
    
    await sut.loadIngredients(scanId: "test-scan")
    
    #expect(sut.statusText == "No ingredients yet")
    #expect(sut.currentIngredients?.isEmpty == true)
  }
  
  @Test("loadIngredients updates status text with count")
  func ingredientController_loadIngredients_withResults() async throws {
    let (sut, _, firestore) = createSUT()
    firestore.mockIngredients = [
      Ingredient(id: "1", name: "Apple", quantity: "5", unit: "whole", category: .other),
      Ingredient(id: "2", name: "Banana", quantity: "3", unit: "whole", category: .other)
    ]
    
    await sut.loadIngredients(scanId: "test-scan")
    
    #expect(sut.statusText == "Loaded 2 ingredients")
  }
  
  // MARK: - Delete Ingredient Tests
  
  @Test("deleteIngredient removes from local state")
  func ingredientController_deleteIngredient_removesLocally() async throws {
    let (sut, _, firestore) = createSUT()
    let ingredientToDelete = Ingredient(id: "del-1", name: "Onion", quantity: "1", unit: "whole", category: .vegetables)
    sut.currentIngredients = [
      ingredientToDelete,
      Ingredient(id: "keep-1", name: "Garlic", quantity: "3", unit: "clove", category: .vegetables)
    ]
    
    await sut.deleteIngredient(scanId: "test-scan", ingredient: ingredientToDelete)
    
    #expect(firestore.deleteIngredientCallCount == 1)
    #expect(sut.currentIngredients?.count == 1)
    #expect(sut.currentIngredients?.first?.name == "Garlic")
  }
  
  @Test("deleteIngredient sets error for ingredient without ID")
  func ingredientController_deleteIngredient_noId_setsError() async throws {
    let (sut, _, _) = createSUT()
    let ingredientWithoutId = Ingredient(id: nil, name: "NoId", quantity: "1", unit: "whole", category: .other)
    
    await sut.deleteIngredient(scanId: "test-scan", ingredient: ingredientWithoutId)
    
    #expect(sut.errorMessage == "Cannot delete: ingredient has no ID")
  }
  
  // MARK: - Add Ingredient Tests
  
  @Test("addIngredient adds to top of list")
  func ingredientController_addIngredient_addsToTop() async throws {
    let (sut, _, firestore) = createSUT()
    sut.currentIngredients = [
      Ingredient(id: "existing-1", name: "Existing", quantity: "1", unit: "cup", category: .other)
    ]
    
    await sut.addIngredient(scanId: "test-scan", name: "New Item", quantity: "2", unit: "tbsp", category: .seasonings)
    
    #expect(firestore.addIngredientCallCount == 1)
    #expect(sut.currentIngredients?.count == 2)
    #expect(sut.currentIngredients?.first?.name == "New Item")
  }
  
  @Test("addIngredient creates list if nil")
  func ingredientController_addIngredient_createsListIfNil() async throws {
    let (sut, _, firestore) = createSUT()
    #expect(sut.currentIngredients == nil)
    
    await sut.addIngredient(scanId: "test-scan", name: "First Item", quantity: "1", unit: "cup", category: .grains)
    
    #expect(firestore.addIngredientCallCount == 1)
    #expect(sut.currentIngredients?.count == 1)
    #expect(sut.currentIngredients?.first?.name == "First Item")
  }
  
  // MARK: - Update Ingredient Tests
  
  @Test("updateIngredient updates local state")
  func ingredientController_updateIngredient_updatesLocally() async throws {
    let (sut, _, firestore) = createSUT()
    let originalIngredient = Ingredient(id: "update-1", name: "OldName", quantity: "1", unit: "cup", category: .grains)
    sut.currentIngredients = [originalIngredient]
    
    await sut.updateIngredient(
      scanId: "test-scan",
      ingredient: originalIngredient,
      name: "NewName",
      quantity: "2",
      unit: "tbsp",
      category: .seasonings
    )
    
    #expect(firestore.updateIngredientCallCount == 1)
    #expect(sut.currentIngredients?.first?.name == "NewName")
    #expect(sut.currentIngredients?.first?.quantity == "2")
    #expect(sut.currentIngredients?.first?.unit == "tbsp")
    #expect(sut.currentIngredients?.first?.category == .seasonings)
  }
  
  @Test("updateIngredient sets error for ingredient without ID")
  func ingredientController_updateIngredient_noId_setsError() async throws {
    let (sut, _, _) = createSUT()
    let ingredientWithoutId = Ingredient(id: nil, name: "NoId", quantity: "1", unit: "whole", category: .other)
    
    await sut.updateIngredient(
      scanId: "test-scan",
      ingredient: ingredientWithoutId,
      name: "Updated",
      quantity: "2",
      unit: "cup",
      category: .grains
    )
    
    #expect(sut.errorMessage == "Cannot update: ingredient has no ID")
  }
  
  // MARK: - IngredientError Tests
  
  @Test("IngredientError invalidImage has correct description")
  func ingredientError_invalidImage_description() async throws {
    let error = IngredientError.invalidImage
    #expect(error.errorDescription == "Invalid image data")
  }
  
  @Test("IngredientError noIngredients has correct description")
  func ingredientError_noIngredients_description() async throws {
    let error = IngredientError.noIngredients
    #expect(error.errorDescription == "No ingredients to save")
  }
}
