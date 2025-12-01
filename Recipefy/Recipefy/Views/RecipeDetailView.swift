//
//  RecipeDetailView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI

struct RecipeDetailView: View {
	let recipe: Recipe
	@State private var selectedTab: DetailTab = .ingredients

	enum DetailTab: String, CaseIterable, Identifiable {
		case ingredients = "Ingredients"
		case steps = "Steps"
		case nutrition = "Nutrition"
		var id: String { rawValue }
	}

	var body: some View {
		VStack(spacing: 0) {
			// Header
			VStack(alignment: .leading, spacing: 8) {
				Text(recipe.title)
					.font(.title2).bold()
					.multilineTextAlignment(.leading)

				HStack(spacing: 10) {
					pill(icon: "flame.fill", text: "\(recipe.calories) cal")
					pill(icon: "clock.fill", text: "\(recipe.cookMin) min")
					pill(icon: "person.2.fill", text: "Serves \(recipe.servings)")
				}
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, 16)
			.padding(.top, 12)
			.padding(.bottom, 8)

			// Tabs (segmented control)
			Picker("Details", selection: $selectedTab) {
				ForEach(DetailTab.allCases) { tab in
					Text(tab.rawValue).tag(tab)
				}
			}
			.pickerStyle(.segmented)
			.padding(.horizontal, 16)
			.padding(.vertical, 8)

			// Content
			TabView(selection: $selectedTab) {
				IngredientsTab(items: recipe.ingredients)
					.tag(DetailTab.ingredients)

				StepsTab(steps: recipe.steps)
					.tag(DetailTab.steps)

				NutritionTab(recipe: recipe)
					.tag(DetailTab.nutrition)
			}
			.tabViewStyle(.page(indexDisplayMode: .never))
		}
	}

	private var shareText: String {
		"""
		\(recipe.title)
		Serves: \(recipe.servings) • \(recipe.cookMin) min • \(recipe.calories) cal

		Ingredients:
		\(recipe.ingredients.joined(separator: "\n"))

		Steps:
		\(recipe.steps.enumerated().map { "\($0.offset+1). \($0.element)" }.joined(separator: "\n"))
		"""
	}

	@ViewBuilder
	private func pill(icon: String, text: String) -> some View {
		HStack(spacing: 6) {
			Image(systemName: icon)
			Text(text).font(.footnote)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 6)
		.background(Capsule().fill(Color.secondary.opacity(0.12)))
	}
}

// MARK: - Tabs

// Ingredients
struct IngredientsTab: View {
	let items: [String]
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				ForEach(items, id: \.self) { item in
					HStack(alignment: .top, spacing: 8) {
						Image(systemName: "circle.fill").font(.system(size: 6)).padding(.top, 7)
						Text(item)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			.padding(16)
		}
	}
}

// Steps
struct StepsTab: View {
	let steps: [String]
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 14) {
			ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
					HStack(alignment: .top, spacing: 10) {
						Text("\(idx + 1).")
							.font(.headline.monospacedDigit())
							.frame(width: 28, alignment: .trailing)
						Text(step)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				}
			}
			.padding(16)
		}
	}
}

// Nutrition
struct NutritionTab: View {
	let recipe: Recipe

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
					macroCard(title: "Protein", value: recipe.protein, unit: "g", icon: "bolt.heart")
					macroCard(title: "Carbs", value: recipe.carbs, unit: "g", icon: "carrot.fill")
					macroCard(title: "Fat", value: recipe.fat, unit: "g", icon: "drop.fill")
					macroCard(title: "Fiber", value: recipe.fiber, unit: "g", icon: "leaf.fill")
					macroCard(title: "Sugar", value: recipe.sugar, unit: "g", icon: "cube.fill")
				}

				if !recipe.description.isEmpty {
					VStack(alignment: .leading, spacing: 8) {
						Text("Notes")
							.font(.headline)
						Text(recipe.description)
							.foregroundColor(.secondary)
					}
				}
			}
			.padding(16)
		}
	}

	@ViewBuilder
	private func macroCard(title: String, value: Int, unit: String, icon: String) -> some View {
			VStack(alignment: .leading, spacing: 8) {
				HStack {
					Image(systemName: icon)
					Text(title).font(.subheadline).foregroundColor(.secondary)
				}
				Text("\(value) \(unit)")
					.font(.title3.bold())
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(14)
			.background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
	}
}

#if DEBUG
struct RecipeDetailView_Previews: PreviewProvider {
	static var previews: some View {
		RecipeDetailView(
			recipe: Recipe(
				recipeID: UUID().uuidString,
				title: "Lemon Garlic Chicken Pasta",
				description: "A bright, zesty pasta with silky garlic sauce.",
				ingredients: ["8 oz spaghetti", "2 tbsp olive oil", "2 cloves garlic", "1 lemon", "1 cup chicken"],
				steps: ["Boil pasta", "Sauté garlic", "Add chicken and lemon", "Toss with pasta"],
				calories: 620, servings: 2, cookMin: 25,
				protein: 32, carbs: 75, fat: 18, fiber: 6, sugar: 1
			)
		)
	}
}
#endif
