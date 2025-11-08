//
//  RecipeView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI

struct RecipeView: View {
	@StateObject var controller = RecipeController()

	var body: some View {
		NavigationStack {
			VStack(spacing: 12) {
				// Status / progress
				if controller.isRetrieving {
					VStack(spacing: 8) {
						ProgressView()
						Text(controller.statusText)
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
				} else if let recipes = controller.currentRecipes, !recipes.isEmpty {
					header(recipesCount: recipes.count)
					// Horizontal, paging cards
					TabView {
						ForEach(recipes, id: \.recipeID) { recipe in
							RecipeCard(recipe: recipe)
								.padding(.horizontal, 16)
								.padding(.vertical, 8)
						}
					}
					.tabViewStyle(.page(indexDisplayMode: .automatic))
					.indexViewStyle(.page(backgroundDisplayMode: .always))
				} else {
					// Idle / empty state
					VStack(spacing: 12) {
						Image(systemName: "fork.knife.circle.fill")
							.font(.system(size: 48))
							.foregroundColor(.accentColor)
						Text("No recipes yet")
							.font(.headline)
						Text(controller.statusText)
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
					.padding(.top, 40)
					Spacer()
				}
			}
			.animation(.easeInOut, value: controller.currentRecipes?.count ?? 0)
			.padding(.top, 8)
		}
	}
	@ViewBuilder
	private func header(recipesCount: Int) -> some View {
		HStack {
			Text("Recipe Suggestions")
				.font(.title2).bold()
			Spacer()
			Text("\(recipesCount)")
				.font(.subheadline.monospacedDigit())
				.foregroundColor(.secondary)
		}
		.padding(.horizontal, 16)
	}
}

// MARK: - Recipe Card

private struct RecipeCard: View {
		let recipe: Recipe

		var body: some View {
			GeometryReader { geo in
				VStack(alignment: .leading, spacing: 12) {
					// Title
					HStack (spacing: 8){
						Text(recipe.title)
							.font(.title3.weight(.semibold))
							.lineLimit(2)
							.minimumScaleFactor(0.8)
						Image(systemName: "heart")
					}
					// Quick facts chips
					HStack(spacing: 8) {
						Chip(icon: "flame.fill", text: "\(recipe.calories) cal")
						Chip(icon: "clock.fill", text: "\(recipe.cookMin) min")
						Chip(icon: "person.2.fill", text: "Serves \(recipe.servings)")
					}
					// Description
					if !recipe.description.isEmpty {
						Text(recipe.description)
							.font(.subheadline)
							.foregroundColor(.secondary)
							.lineLimit(3)
					}

					// Ingredients / Steps previews
					VStack(alignment: .leading, spacing: 8) {
						if !recipe.ingredients.isEmpty {
							LabeledBulletList(label: "Ingredients",
																items: recipe.ingredients.prefix(5),
																moreCount: recipe.ingredients.count - 5)
						}
					}
					.padding(.top, 4)

					Spacer(minLength: 0)
					NavigationLink {
						RecipeDetailView(recipe: recipe)
						} label: {
							Label("View Details", systemImage: "arrow.right.circle.fill")
									.font(.headline)
									.frame(maxWidth: .infinity)
						}
						.buttonStyle(.borderedProminent)
						.padding(.horizontal, 16)
					
			}
			.padding(16)
			.frame(width: min(geo.size.width, 520)) // nice max width for larger devices
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			.background(
					RoundedRectangle(cornerRadius: 20, style: .continuous)
							.fill(.background)
							.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
			)
		}
		.frame(height: 450)
	}
}

// MARK: - Small Components

private struct Chip: View {
	let icon: String
	let text: String
	var body: some View {
		HStack(spacing: 6) {
			Image(systemName: icon)
			Text(text)
				.font(.footnote)
		}
		.padding(.horizontal, 10)
		.padding(.vertical, 6)
		.background(
			Capsule(style: .circular)
				.fill(Color.secondary.opacity(0.12))
		)
	}
}

private struct LabeledBulletList: View {
	let label: String
	let items: ArraySlice<String>
	let moreCount: Int
	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			Text(label)
				.font(.footnote.weight(.semibold))
				.foregroundColor(.secondary)
			ForEach(Array(items.enumerated()), id: \.offset) { _, item in
				HStack(alignment: .top, spacing: 6) {
					Circle().frame(width: 4, height: 4)
						.foregroundColor(.secondary)
						.padding(.top, 6)
					Text(item)
						.font(.subheadline)
						.foregroundColor(.primary)
						.lineLimit(1)
						.truncationMode(.tail)
				}
			}
			if moreCount > 0 {
				Text("+\(moreCount) more")
					.font(.footnote)
					.foregroundColor(.secondary)
			}
		}
	}
}

// MARK: - Preview with mock data

#if DEBUG
struct RecipeView_Previews: PreviewProvider {
	static var previews: some View {
		let controller = RecipeController()
		controller.currentRecipes = [
			Recipe(
				recipeID: UUID().uuidString,
				title: "Lemon Garlic Chicken Pasta",
				description: "A bright, zesty pasta with silky garlic sauce.",
				ingredients: ["8 oz spaghetti", "2 tbsp olive oil", "2 cloves garlic", "1 lemon", "1 cup chicken"],
				steps: ["Boil pasta", "Sauté garlic", "Add chicken and lemon", "Toss with pasta"],
				calories: 620, servings: 2, cookMin: 25,
				protein: 32, carbs: 75, fat: 18, fiber: 6
			),
			Recipe(
				recipeID: UUID().uuidString,
				title: "Tomato Basil Soup",
				description: "Creamy tomato soup with fresh basil.",
				ingredients: ["3 cups tomatoes", "1 onion", "2 cups stock", "Basil"],
				steps: ["Sauté onion", "Simmer tomatoes & stock", "Blend & add basil"],
				calories: 280, servings: 3, cookMin: 30,
				protein: 8, carbs: 36, fat: 10, fiber: 5
			)
		]
		return NavigationStack {
			RecipeView(controller: controller)
				.preferredColorScheme(.light)
		}
	}
}
#endif



#Preview {
	NavigationStack {
		RecipeView()
	}
}

