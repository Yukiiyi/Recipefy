//
//  RecipeTests.swift
//  RecipefyTests
//
//  Created by Jonass Oh on 11/8/25.
//

import Testing
import Foundation
@testable import Recipefy

@MainActor
struct RecipeTests {

		// MARK: - RecipeController

		@Test
		func initialState_defaults() async throws {
				let sut = RecipeController()

				#expect(sut.statusText == "Idle")
				#expect(sut.currentRecipes == nil)
				#expect(sut.isRetrieving == false)
				#expect(sut.isSaving == false)
				#expect(sut.saveSuccess == false)
		}

		@Test
		func saveRecipe_whenNoCurrentRecipes_setsMessageAndDoesNotToggleSaving() async throws {
				let sut = RecipeController()

				// Precondition
				#expect(sut.currentRecipes == nil)

				// Act
				try await sut.saveRecipe()

				// Assert
				#expect(sut.statusText == "No recipes to save")
				#expect(sut.isSaving == false)
				#expect(sut.saveSuccess == false)
		}

		// MARK: - Models (pure mapping tests, no Firebase/Gemini needed)

		@Test
		func recipe_initFromRawRecipe_mapsAllFields() async throws {
				// Given
				let nutrition = Nutrition(protein: 25, carbs: 50, fat: 10, fiber: 6, description: "Balanced meal")
				let raw = RawRecipe(
						recipeID: "raw-123",
						title: "Test Bowl",
						ingredients: ["1 cup rice", "200g chicken", "1 tbsp oil"],
						steps: ["Cook rice", "Sear chicken", "Combine"],
						cookMin: 30,
						calories: 600,
						servings: 2,
						nutrition: nutrition
				)

				// When
				let mapped = Recipe(from: raw)

				// Then
				#expect(mapped.title == "Test Bowl")
				#expect(mapped.description == "Balanced meal")
				#expect(mapped.ingredients.count == 3)
				#expect(mapped.steps.count == 3)
				#expect(mapped.cookMin == 30)
				#expect(mapped.calories == 600)
				#expect(mapped.servings == 2)
				#expect(mapped.protein == 25)
				#expect(mapped.carbs == 50)
				#expect(mapped.fat == 10)
				#expect(mapped.fiber == 6)

				// UUID should be non-empty and different from raw id
				#expect(!mapped.recipeID.isEmpty)
				#expect(mapped.recipeID != raw.recipeID)
		}

		@Test
		func ingredient_dictionary_roundTrip() async throws {
				// Given
				let ingredient = Ingredient(name: "Tomato", amount: "2 cups")

				// When
				let dict = ingredient.toDictionary()
				let roundTripped = Ingredient.from(dictionary: dict)

				// Then
				#expect(dict["name"] == "Tomato")
				#expect(dict["amount"] == "2 cups")
				#expect(roundTripped?.name == "Tomato")
				#expect(roundTripped?.amount == "2 cups")
		}
}
