//
//  GeminiService.swift
//  Recipefy
//
//  Created by yuqi zou on 10/25/25.
//

import Foundation
import UIKit
import FirebaseAI

class GeminiService {
  private let model: GenerativeModel
  
  init() {
    let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    print("✅ GeminiService initialized with Gemini 2.5 Flash")
  }
  
  func analyzeIngredients(image: UIImage) async throws -> [Ingredient] {
    let prompt = """
    Analyze this food image and identify all the ingredients you can see.
    For each ingredient, provide the name, estimated amount, and food category.
    
    Categories should be one of: [Vegetables, Proteins, Grains, Dairy, Seasonings, Oil, Other].
    Return the result as a JSON array with this exact format:
    [
      {
        "name": "ingredient name",
        "amount": "estimated amount (e.g., '2 cups', '1 tbsp', '500 g', '3 pieces')",
        "category": "appropriate category from the list above"
      }
    ]
    
    If you cannot determine the exact amount, make a reasonable estimate based on what you see.
    Return ONLY the JSON array, no additional text.
    """
    
    let response = try await model.generateContent(prompt, image)
    guard let text = response.text else {
      throw GeminiError.noResponse
    }
    
    return try parseIngredientsResponse(from: text)
  }
  
  private func parseIngredientsResponse(from jsonString: String) throws -> [Ingredient] {
    let cleanJson = jsonString
      .replacingOccurrences(of: "```json", with: "")
      .replacingOccurrences(of: "```", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    guard let data = cleanJson.data(using: .utf8) else {
      throw GeminiError.parsingError
    }
    
    let decoder = JSONDecoder()
    return try decoder.decode([Ingredient].self, from: data)
  }
	
	func getRecipe(ingredients: [String]) async throws -> [Recipe] {
		let prompt = """
		This is a list of the available ingredients: \(ingredients)
		Provide 5 unique recipes that can be made using only the amount of ingredients listed. 
		For each recipe, provide the name, calories, serving size, list of preparation steps (e.g. ["Boil water and cook pasta according to package directions", "Heat olive oil in a large pan over medium heat", ...]) , preparation time in minutes,  list of ingredients used (e.g. ["1 cup tomatoes", "1 lb Chicken Breast", ...]) , nutrition information in a map which contains the amount of carbs, fat, fiber, protein, and a description.
		
		Return the result as a JSON array with this exact format:
		[
			{
				"title": "recipe name",
				"servings": serving_size_as_an_integer,
				"calories": calories_as_an_integer,
				"cookMin": preparation_time_in_minutes_as_an_integer,
				"ingredients": ["list", "of", "ingredients"],
				"nutrition": {
					"carbs": carbs_as_an_integer, 
					"fat": fat_as_an_integer, 
					"fiber": fiber_as_an_integer, 
					"protein": protein_as_an_integer, 
					"description": "description text"
				},
				"steps": ["list", "of", "preparation", "steps"]
			}
		]
		
		All fields with the tag "_as_an_integer" should be of type Integer.
		Return ONLY the JSON array, no additional text.
		"""
		
		let response = try await model.generateContent(prompt)
		guard let text = response.text else {
			throw GeminiError.noResponse
		}
		
		return try parseRecipeResponse(from: text)
	}
	
	private func parseRecipeResponse(from jsonString: String) throws -> [Recipe] {
		// Clean JSON response (remove markdown code blocks like ingredients parsing does)
		let cleanJson = jsonString
			.replacingOccurrences(of: "```json", with: "")
			.replacingOccurrences(of: "```", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)
		
		guard let data = cleanJson.data(using: .utf8) else {
			throw GeminiError.parsingError
		}
		
		let rawRecipes = try JSONDecoder().decode([RawRecipe].self, from: data)
		let recipes = rawRecipes.map(Recipe.init)
		return recipes
	}
}

enum GeminiError: LocalizedError {
  case noResponse
  case parsingError
  case invalidImage
  
  var errorDescription: String? {
    switch self {
    case .noResponse:
      return "No response from Gemini AI"
    case .parsingError:
      return "Failed to parse AI response"
    case .invalidImage:
      return "Invalid image data"
    }
  }
}

