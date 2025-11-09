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

		// UUID should be generated and non-empty
		#expect(!mapped.recipeID.isEmpty)
	}

	@Test
	func ingredient_dictionary_roundTrip() async throws {
		// Given
		let ingredient = Ingredient(id: nil, name: "Tomato", amount: "2 cups", category: .vegetables)

		// When
		let dict = ingredient.toDictionary()
		let roundTripped = Ingredient.from(dictionary: dict)

		// Then
		#expect(dict["name"] == "Tomato")
		#expect(dict["amount"] == "2 cups")
		#expect(dict["category"] == "Vegetables")
		#expect(roundTripped?.name == "Tomato")
		#expect(roundTripped?.amount == "2 cups")
		#expect(roundTripped?.category == .vegetables)
	}
}
