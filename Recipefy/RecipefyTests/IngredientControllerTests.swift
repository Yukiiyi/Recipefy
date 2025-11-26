//
//  IngredientControllerTests.swift
//  RecipefyTests
//
//  Created by AI Assistant on 11/10/25.
//

import Testing
import Foundation
@testable import Recipefy

@MainActor
struct IngredientControllerTests {
  
  // MARK: - Initialization Tests
  
  @Test("IngredientController initializes with correct default state")
  func ingredientController_initialState_defaults() async throws {
    let sut = IngredientController()
    
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
    let sut = IngredientController()
    
    sut.statusText = "Analyzing..."
    #expect(sut.statusText == "Analyzing...")
    
    sut.statusText = "Complete"
    #expect(sut.statusText == "Complete")
  }
  
  @Test("IngredientController isAnalyzing flag toggles")
  func ingredientController_isAnalyzing_toggles() async throws {
    let sut = IngredientController()
    
    #expect(sut.isAnalyzing == false)
    
    sut.isAnalyzing = true
    #expect(sut.isAnalyzing == true)
    
    sut.isAnalyzing = false
    #expect(sut.isAnalyzing == false)
  }
  
  @Test("IngredientController saveSuccess flag toggles")
  func ingredientController_saveSuccess_toggles() async throws {
    let sut = IngredientController()
    
    #expect(sut.saveSuccess == false)
    
    sut.saveSuccess = true
    #expect(sut.saveSuccess == true)
  }
  
  @Test("IngredientController errorMessage can be set and cleared")
  func ingredientController_errorMessage_canSetAndClear() async throws {
    let sut = IngredientController()
    
    #expect(sut.errorMessage == nil)
    
    sut.errorMessage = "Test error"
    #expect(sut.errorMessage == "Test error")
    
    sut.errorMessage = nil
    #expect(sut.errorMessage == nil)
  }
  
  @Test("IngredientController currentScanId can be set")
  func ingredientController_currentScanId_canSet() async throws {
    let sut = IngredientController()
    
    sut.currentScanId = "scan-123"
    #expect(sut.currentScanId == "scan-123")
  }
  
  // MARK: - Ingredients List Tests
  
  @Test("IngredientController can store ingredients list")
  func ingredientController_canStoreIngredients() async throws {
    let sut = IngredientController()
    
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
    let sut = IngredientController()
    
    sut.currentIngredients = []
    
    #expect(sut.currentIngredients?.isEmpty == true)
    #expect(sut.currentIngredients?.count == 0)
  }
  
  @Test("IngredientController can clear ingredients")
  func ingredientController_canClearIngredients() async throws {
    let sut = IngredientController()
    
    sut.currentIngredients = [
      Ingredient(id: "1", name: "Tomato", quantity: "3", unit: "whole", category: .vegetables)
    ]
    
    #expect(sut.currentIngredients?.count == 1)
    
    sut.currentIngredients = nil
    #expect(sut.currentIngredients == nil)
  }
  
  // MARK: - Status Message Tests
  
  @Test("IngredientController status messages follow expected patterns")
  func ingredientController_statusMessages_followPatterns() async throws {
    let sut = IngredientController()
    
    let validStatuses = [
      "Idle",
      "Analyzing ingredients with AI...",
      "Analyzing image 1 of 3...",
      "Saving 5 ingredients...",
      "Loading ingredients...",
      "Loaded 10 ingredients"
    ]
    
    for status in validStatuses {
      sut.statusText = status
      #expect(!sut.statusText.isEmpty)
    }
  }
  
  @Test("IngredientController handles error status messages")
  func ingredientController_handlesErrorStatuses() async throws {
    let sut = IngredientController()
    
    sut.statusText = "Error: Failed to analyze"
    #expect(sut.statusText.contains("Error"))
    
    sut.statusText = "Save error: Network issue"
    #expect(sut.statusText.contains("error"))
  }
  
  // MARK: - State Consistency Tests
  
  @Test("IngredientController analyzing state is consistent")
  func ingredientController_analyzingState_consistent() async throws {
    let sut = IngredientController()
    
    // When analyzing starts
    sut.isAnalyzing = true
    sut.statusText = "Analyzing..."
    
    #expect(sut.isAnalyzing == true)
    #expect(sut.statusText.contains("Analyzing"))
    
    // When analyzing completes
    sut.isAnalyzing = false
    sut.statusText = "Complete"
    
    #expect(sut.isAnalyzing == false)
  }
  
  @Test("IngredientController can reset to initial state")
  func ingredientController_canReset() async throws {
    let sut = IngredientController()
    
    // Set some state
    sut.statusText = "Processing..."
    sut.currentIngredients = [Ingredient(id: "1", name: "Test", quantity: "1", unit: "cup", category: .other)]
    sut.isAnalyzing = true
    sut.saveSuccess = true
    sut.errorMessage = "Some error"
    sut.currentScanId = "scan-123"
    
    // Reset to defaults
    sut.statusText = "Idle"
    sut.currentIngredients = nil
    sut.isAnalyzing = false
    sut.saveSuccess = false
    sut.errorMessage = nil
    sut.currentScanId = nil
    
    // Verify reset
    #expect(sut.statusText == "Idle")
    #expect(sut.currentIngredients == nil)
    #expect(sut.isAnalyzing == false)
    #expect(sut.saveSuccess == false)
    #expect(sut.errorMessage == nil)
    #expect(sut.currentScanId == nil)
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

