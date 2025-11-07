//
//  IngredientTests.swift
//  RecipefyTests
//
//  Created by streak honey on 11/5/25.
//

import Testing
import Foundation
@testable import Recipefy

struct IngredientTests {
  
  // MARK: - Ingredient Model Tests
  
  @Test("Ingredient creation with all fields")
  func ingredientCreation() {
    let ingredient = Ingredient(
      id: "test-id",
      name: "Chicken",
      amount: "500g",
      category: "Proteins"
    )
    
    #expect(ingredient.id == "test-id")
    #expect(ingredient.name == "Chicken")
    #expect(ingredient.amount == "500g")
    #expect(ingredient.category == "Proteins")
  }
  
  @Test("Converting ingredient to dictionary")
  func ingredientToDictionary() {
    let ingredient = Ingredient(
      id: "test-id",
      name: "Rice",
      amount: "2 cups",
      category: "Grains"
    )
    
    let dictionary = ingredient.toDictionary()
    
    #expect(dictionary["name"] == "Rice")
    #expect(dictionary["amount"] == "2 cups")
    #expect(dictionary["category"] == "Grains")
  }
  
  @Test("Creating ingredient from valid dictionary")
  func ingredientFromDictionary() {
    let dictionary = [
      "name": "Tomato",
      "amount": "3 pieces",
      "category": "Vegetables"
    ]
    
    let ingredient = Ingredient.from(dictionary: dictionary)
    
    #expect(ingredient != nil)
    #expect(ingredient?.name == "Tomato")
    #expect(ingredient?.amount == "3 pieces")
    #expect(ingredient?.category == "Vegetables")
  }
  
  @Test("Creating ingredient from dictionary with missing field returns nil")
  func ingredientFromDictionary_MissingField() {
    let dictionary = [
      "name": "Tomato",
      "category": "Vegetables"
      // Missing "amount"
    ]
    
    let ingredient = Ingredient.from(dictionary: dictionary)
    
    #expect(ingredient == nil)
  }
  
  // MARK: - JSON Parsing Tests
  
  @Test("Parsing valid JSON response")
  func parseValidJSON() throws {
    let jsonString = """
    [
      {
        "name": "Chicken Breast",
        "amount": "500 g",
        "category": "Proteins"
      },
      {
        "name": "Rice",
        "amount": "2 cups",
        "category": "Grains"
      }
    ]
    """
    
    let jsonData = try #require(jsonString.data(using: .utf8))
    let decoder = JSONDecoder()
    let ingredients = try decoder.decode([Ingredient].self, from: jsonData)
    
    #expect(ingredients.count == 2)
    #expect(ingredients[0].name == "Chicken Breast")
    #expect(ingredients[1].category == "Grains")
  }
  
  @Test("Parsing JSON wrapped in code blocks")
  func parseJSONWithCodeBlocks() throws {
    let jsonString = """
    ```json
    [
      {
        "name": "Tomato",
        "amount": "3 pieces",
        "category": "Vegetables"
      }
    ]
    ```
    """
    
    // Clean the JSON (like GeminiService does)
    let cleanJson = jsonString
      .replacingOccurrences(of: "```json", with: "")
      .replacingOccurrences(of: "```", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    let jsonData = try #require(cleanJson.data(using: .utf8))
    let decoder = JSONDecoder()
    let ingredients = try decoder.decode([Ingredient].self, from: jsonData)
    
    #expect(ingredients.count == 1)
    #expect(ingredients[0].name == "Tomato")
  }
  
  // MARK: - Category Validation Tests
  
  @Test("All valid categories are accepted",
        arguments: ["Vegetables", "Proteins", "Grains", "Dairy", "Seasonings", "Oil", "Other"])
  func validCategories(category: String) {
    let ingredient = Ingredient(id: nil, name: "Test", amount: "1", category: category)
    #expect(ingredient.category == category)
  }
  
  // MARK: - Edge Cases
  
  @Test("Ingredient with special characters")
  func ingredientWithSpecialCharacters() {
    let ingredient = Ingredient(
      id: "test",
      name: "Jalapeño Peppers",
      amount: "1/4 cup",
      category: "Vegetables"
    )
    
    #expect(ingredient.name == "Jalapeño Peppers")
    #expect(ingredient.amount == "1/4 cup")
  }
  
  @Test("Ingredient with empty strings")
  func ingredientWithEmptyStrings() {
    let ingredient = Ingredient(
      id: "test",
      name: "",
      amount: "",
      category: ""
    )
    
    // Just verifying it can be created
    #expect(ingredient.name == "")
    // Note: In real app, you'd want validation to prevent this
  }
}

