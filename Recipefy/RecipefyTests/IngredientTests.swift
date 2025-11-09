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
      category: .proteins
    )
    
    #expect(ingredient.id == "test-id")
    #expect(ingredient.name == "Chicken")
    #expect(ingredient.amount == "500g")
    #expect(ingredient.category == .proteins)
  }
  
  @Test("Converting ingredient to dictionary")
  func ingredientToDictionary() {
    let ingredient = Ingredient(
      id: "test-id",
      name: "Rice",
      amount: "2 cups",
      category: .grains
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
    #expect(ingredient?.category == .vegetables)
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
    #expect(ingredients[1].category == .grains)
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
  
  @Test("All valid categories are accepted")
  func validCategories() {
    let categories: [IngredientCategory] = [.vegetables, .proteins, .grains, .dairy, .seasonings, .oil, .other]
    
    for category in categories {
      let ingredient = Ingredient(id: nil, name: "Test", amount: "1", category: category)
      #expect(ingredient.category == category)
    }
  }
  
  @Test("Category validation from string - exact matches")
  func categoryFromStringExact() {
    #expect(IngredientCategory.from(string: "Vegetables") == .vegetables)
    #expect(IngredientCategory.from(string: "Proteins") == .proteins)
    #expect(IngredientCategory.from(string: "Grains") == .grains)
    #expect(IngredientCategory.from(string: "Dairy") == .dairy)
    #expect(IngredientCategory.from(string: "Seasonings") == .seasonings)
    #expect(IngredientCategory.from(string: "Oil") == .oil)
    #expect(IngredientCategory.from(string: "Other") == .other)
  }
  
  @Test("Category validation from string - case variations")
  func categoryFromStringCaseInsensitive() {
    #expect(IngredientCategory.from(string: "vegetables") == .vegetables)
    #expect(IngredientCategory.from(string: "PROTEINS") == .proteins)
    #expect(IngredientCategory.from(string: "Vegetable") == .vegetables)
    #expect(IngredientCategory.from(string: "protein") == .proteins)
  }
  
  @Test("Category validation from string - invalid defaults to other")
  func categoryFromStringInvalid() {
    #expect(IngredientCategory.from(string: "Fruits") == .other)
    #expect(IngredientCategory.from(string: "Invalid") == .other)
    #expect(IngredientCategory.from(string: "") == .other)
    #expect(IngredientCategory.from(string: "123") == .other)
  }
  
  // MARK: - Edge Cases
  
  @Test("Ingredient with special characters")
  func ingredientWithSpecialCharacters() {
    let ingredient = Ingredient(
      id: "test",
      name: "Jalapeño Peppers",
      amount: "1/4 cup",
      category: .vegetables
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
      category: .other
    )
    
    // Just verifying it can be created
    #expect(ingredient.name == "")
    // Note: In real app, you'd want validation to prevent this
  }
}

