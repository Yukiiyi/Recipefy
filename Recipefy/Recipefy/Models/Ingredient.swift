//
//  Ingredient.swift
//  Recipefy
//
//  Created by streak honey on 11/8/25.
//

import Foundation

// MARK: - Category Enum

enum IngredientCategory: String, Codable, CaseIterable {
  case vegetables = "Vegetables"
  case proteins = "Proteins"
  case grains = "Grains"
  case dairy = "Dairy"
  case seasonings = "Seasonings"
  case oil = "Oil"
  case other = "Other"
  
  /// Validates and normalizes category strings from AI responses
  /// Falls back to `.other` for unrecognized values
  static func from(string: String) -> IngredientCategory {
    // Try exact match first
    if let category = IngredientCategory(rawValue: string) {
      return category
    }
    
    // Handle common variations (case-insensitive, singular/plural)
    let normalized = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    switch normalized {
    case "vegetable", "vegetables", "veggie", "veggies", "veg":
      return .vegetables
    case "protein", "proteins", "meat", "meats":
      return .proteins
    case "grain", "grains", "carb", "carbs", "carbohydrate", "carbohydrates":
      return .grains
    case "dairy":
      return .dairy
    case "seasoning", "seasonings", "spice", "spices", "herb", "herbs":
      return .seasonings
    case "oil", "oils", "fat", "fats":
      return .oil
    default:
      return .other
    }
  }
}

// MARK: - Ingredient Model

struct Ingredient: Identifiable {
  var id: String?
  let name: String
  let quantity: String
  let unit: String
  let category: IngredientCategory
  
  /// Computed property for displaying the full amount
  var amount: String {
    "\(quantity) \(unit)"
  }
}

// MARK: - Codable Conformance

extension Ingredient: Codable {
  /// Custom decoder validates AI-generated category strings
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    quantity = try container.decode(String.self, forKey: .quantity)
    unit = try container.decode(String.self, forKey: .unit)
    
    // Validate category from potentially invalid AI response
    let categoryString = try container.decode(String.self, forKey: .category)
    category = IngredientCategory.from(string: categoryString)
  }
}

// MARK: - Dictionary Helpers

extension Ingredient {
  /// Convert to dictionary (useful for testing and manual Firestore operations)
  func toDictionary() -> [String: String] {
    return [
      "name": name,
      "quantity": quantity,
      "unit": unit,
      "category": category.rawValue
    ]
  }
  
  /// Create from dictionary with category validation
  static func from(dictionary: [String: String]) -> Ingredient? {
    guard let name = dictionary["name"],
          let quantity = dictionary["quantity"],
          let unit = dictionary["unit"],
          let categoryString = dictionary["category"] else {
      return nil
    }
    let category = IngredientCategory.from(string: categoryString)
    return Ingredient(id: nil, name: name, quantity: quantity, unit: unit, category: category)
  }
}
