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
      quantity: "500",
      unit: "gram",
      category: .proteins
    )
    
    #expect(ingredient.id == "test-id")
    #expect(ingredient.name == "Chicken")
    #expect(ingredient.quantity == "500")
    #expect(ingredient.unit == "gram")
    #expect(ingredient.amount == "500 gram")
    #expect(ingredient.category == .proteins)
  }
  
  @Test("Converting ingredient to dictionary")
  func ingredientToDictionary() {
    let ingredient = Ingredient(
      id: "test-id",
      name: "Rice",
      quantity: "2",
      unit: "cup",
      category: .grains
    )
    
    let dictionary = ingredient.toDictionary()
    
    #expect(dictionary["name"] == "Rice")
    #expect(dictionary["quantity"] == "2")
    #expect(dictionary["unit"] == "cup")
    #expect(dictionary["category"] == "Grains")
  }
  
  @Test("Creating ingredient from valid dictionary")
  func ingredientFromDictionary() {
    let dictionary = [
      "name": "Tomato",
      "quantity": "3",
      "unit": "piece",
      "category": "Vegetables"
    ]
    
    let ingredient = Ingredient.from(dictionary: dictionary)
    
    #expect(ingredient != nil)
    #expect(ingredient?.name == "Tomato")
    #expect(ingredient?.quantity == "3")
    #expect(ingredient?.unit == "piece")
    #expect(ingredient?.amount == "3 piece")
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
        "quantity": "500",
        "unit": "gram",
        "category": "Proteins"
      },
      {
        "name": "Rice",
        "quantity": "2",
        "unit": "cup",
        "category": "Grains"
      }
    ]
    """
    
    let jsonData = try #require(jsonString.data(using: .utf8))
    let decoder = JSONDecoder()
    let ingredients = try decoder.decode([Ingredient].self, from: jsonData)
    
    #expect(ingredients.count == 2)
    #expect(ingredients[0].name == "Chicken Breast")
    #expect(ingredients[0].quantity == "500")
    #expect(ingredients[0].unit == "gram")
    #expect(ingredients[1].category == .grains)
  }
  
  @Test("Parsing JSON wrapped in code blocks")
  func parseJSONWithCodeBlocks() throws {
    let jsonString = """
    ```json
    [
      {
        "name": "Tomato",
        "quantity": "3",
        "unit": "piece",
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
    #expect(ingredients[0].quantity == "3")
    #expect(ingredients[0].unit == "piece")
  }
  
  // MARK: - Category Validation Tests
  
  @Test("All valid categories are accepted")
  func validCategories() {
    let categories: [IngredientCategory] = [.vegetables, .proteins, .grains, .dairy, .seasonings, .oil, .other]
    
    for category in categories {
      let ingredient = Ingredient(id: nil, name: "Test", quantity: "1", unit: "cup", category: category)
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
      quantity: "0.25",
      unit: "cup",
      category: .vegetables
    )
    
    #expect(ingredient.name == "Jalapeño Peppers")
    #expect(ingredient.quantity == "0.25")
    #expect(ingredient.unit == "cup")
    #expect(ingredient.amount == "0.25 cup")
  }
  
  @Test("Ingredient with empty strings")
  func ingredientWithEmptyStrings() {
    let ingredient = Ingredient(
      id: "test",
      name: "",
      quantity: "",
      unit: "",
      category: .other
    )
    
    // Just verifying it can be created
    #expect(ingredient.name == "")
    #expect(ingredient.quantity == "")
    #expect(ingredient.unit == "")
    // Note: In real app, you'd want validation to prevent this
  }
}

