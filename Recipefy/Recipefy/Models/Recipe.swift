//
//  Recipe.swift
//  Recipefy
//
//  Created by streak honey on 11/8/25.
//

import Foundation

// MARK: - Recipe Model

struct Recipe: Codable {
  let recipeID: String
  let title: String
  let description: String
  let ingredients: [String]
  let steps: [String]
  let calories: Int
  let servings: Int
  let cookMin: Int
  let protein: Int
  let carbs: Int
  let fat: Int
  let fiber: Int
  var favorited: Bool = false
}

// MARK: - Supporting Types

struct Nutrition: Codable {
  let protein: Int
  let carbs: Int
  let fat: Int
  let fiber: Int
  let description: String //default to not saved
}

struct RawRecipe: Codable {
  let title: String
  let ingredients: [String]
  let steps: [String]
  let cookMin: Int
  let calories: Int
  let servings: Int
  let nutrition: Nutrition
	var favorited: Bool = false
}

// MARK: - Recipe Conversion

extension Recipe {
  init(from raw: RawRecipe) {
    self.recipeID = UUID().uuidString
    self.title = raw.title
    self.description = raw.nutrition.description
    self.ingredients = raw.ingredients
    self.steps = raw.steps
    self.calories = raw.calories
    self.servings = raw.servings
    self.cookMin = raw.cookMin
    self.protein = raw.nutrition.protein
    self.carbs = raw.nutrition.carbs
    self.fat = raw.nutrition.fat
    self.fiber = raw.nutrition.fiber
    self.favorited = raw.favorited
  }
}

