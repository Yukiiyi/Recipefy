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
    For each ingredient, provide the name and estimated amount.
    
    Return the result as a JSON array with this exact format:
    [
      {
        "name": "ingredient name",
        "amount": "estimated amount (e.g., '2 cups', '1 tbsp', '500g', '3 pieces')"
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
}

struct Ingredient: Codable {
  let name: String
  let amount: String
  
  func toDictionary() -> [String: String] {
    return ["name": name, "amount": amount]
  }
  
  static func from(dictionary: [String: String]) -> Ingredient? {
    guard let name = dictionary["name"], let amount = dictionary["amount"] else {
      return nil
    }
    return Ingredient(name: name, amount: amount)
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
