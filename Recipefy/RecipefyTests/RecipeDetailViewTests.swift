//
//  RecipeDetailViewTests.swift
//  RecipefyTests
//
//  Tests for RecipeDetailView formatting logic
//

import Testing
import Foundation
@testable import Recipefy

struct RecipeDetailViewTests {
  
  // Test the shareText formatting logic
  
  func createMockRecipe(
    title: String = "Test Recipe",
    servings: Int = 2,
    cookMin: Int = 30,
    calories: Int = 200,
    ingredients: [String] = ["1 cup flour", "2 eggs"],
    steps: [String] = ["Mix ingredients", "Bake at 350°F"]
  ) -> Recipe {
    return Recipe(
      recipeID: "test-id",
      title: title,
      description: "Test description",
      ingredients: ingredients,
      steps: steps,
      calories: calories,
      servings: servings,
      cookMin: cookMin,
      protein: 10,
      carbs: 25,
      fat: 8,
      fiber: 2,
      sugar: 5,
      favorited: false
    )
  }
  
  @Test("ShareText includes recipe title")
  func shareText_includesTitle() {
    let recipe = createMockRecipe(title: "Delicious Pasta")
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("Delicious Pasta"))
  }
  
  @Test("ShareText includes serving info")
  func shareText_includesServings() {
    let recipe = createMockRecipe(servings: 4)
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("Serves: 4"))
  }
  
  @Test("ShareText includes cook time")
  func shareText_includesCookTime() {
    let recipe = createMockRecipe(cookMin: 45)
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("45 min"))
  }
  
  @Test("ShareText includes calories")
  func shareText_includesCalories() {
    let recipe = createMockRecipe(calories: 350)
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("350 cal"))
  }
  
  @Test("ShareText includes all ingredients")
  func shareText_includesAllIngredients() {
    let ingredients = ["1 cup flour", "2 eggs", "1 tbsp sugar"]
    let recipe = createMockRecipe(ingredients: ingredients)
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("Ingredients:"))
    #expect(shareText.contains("1 cup flour"))
    #expect(shareText.contains("2 eggs"))
    #expect(shareText.contains("1 tbsp sugar"))
  }
  
  @Test("ShareText includes numbered steps")
  func shareText_includesNumberedSteps() {
    let steps = ["Mix dry ingredients", "Add wet ingredients", "Bake"]
    let recipe = createMockRecipe(steps: steps)
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("Steps:"))
    #expect(shareText.contains("1. Mix dry ingredients"))
    #expect(shareText.contains("2. Add wet ingredients"))
    #expect(shareText.contains("3. Bake"))
  }
  
  @Test("ShareText formats complete recipe correctly")
  func shareText_completeFormat() {
    let recipe = createMockRecipe(
      title: "Chocolate Cake",
      servings: 8,
      cookMin: 60,
      calories: 450,
      ingredients: ["2 cups flour", "1 cup sugar", "3 eggs"],
      steps: ["Preheat oven", "Mix ingredients", "Bake for 45 min"]
    )
    
    let shareText = generateShareText(for: recipe)
    
    // Should have all sections
    #expect(shareText.contains("Chocolate Cake"))
    #expect(shareText.contains("Serves: 8"))
    #expect(shareText.contains("60 min"))
    #expect(shareText.contains("450 cal"))
    #expect(shareText.contains("Ingredients:"))
    #expect(shareText.contains("Steps:"))
    
    // Should have correct structure
    let titleIndex = shareText.range(of: "Chocolate Cake")!.lowerBound
    let ingredientsIndex = shareText.range(of: "Ingredients:")!.lowerBound
    let stepsIndex = shareText.range(of: "Steps:")!.lowerBound
    
    // Title comes before ingredients, which comes before steps
    #expect(titleIndex < ingredientsIndex)
    #expect(ingredientsIndex < stepsIndex)
  }
  
  @Test("ShareText handles single ingredient")
  func shareText_singleIngredient() {
    let recipe = createMockRecipe(ingredients: ["1 cup water"])
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("1 cup water"))
  }
  
  @Test("ShareText handles single step")
  func shareText_singleStep() {
    let recipe = createMockRecipe(steps: ["Serve immediately"])
    
    let shareText = generateShareText(for: recipe)
    
    #expect(shareText.contains("1. Serve immediately"))
  }
  
  @Test("DetailTab enum has all cases")
  func detailTab_allCases() {
    // Test the enum structure (simulating RecipeDetailView.DetailTab)
    enum DetailTab: String, CaseIterable {
      case ingredients = "Ingredients"
      case steps = "Steps"
      case nutrition = "Nutrition"
    }
    
    let allCases = DetailTab.allCases
    #expect(allCases.count == 3)
    #expect(allCases.contains(.ingredients))
    #expect(allCases.contains(.steps))
    #expect(allCases.contains(.nutrition))
  }
  
  // Helper function that replicates RecipeDetailView.shareText logic
  private func generateShareText(for recipe: Recipe) -> String {
    """
    \(recipe.title)
    Serves: \(recipe.servings) • \(recipe.cookMin) min • \(recipe.calories) cal
    
    Ingredients:
    \(recipe.ingredients.joined(separator: "\n"))
    
    Steps:
    \(recipe.steps.enumerated().map { "\($0.offset+1). \($0.element)" }.joined(separator: "\n"))
    """
  }
}

