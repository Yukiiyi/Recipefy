//
//  RecipeView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI

struct RecipeView: View {
	@EnvironmentObject var controller: RecipeController
	let ingredients: [Ingredient]
	let scanId: String?

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
					RecipeCardsView(recipes: recipes)
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
			.task(id: scanId) {
				// Only runs when scanId changes (or first time)
				// Generate recipes if we don't have any for this scan
				if controller.lastGeneratedScanId != scanId && !controller.isRetrieving {
					await controller.getRecipe(ingredients: ingredients, sourceScanId: scanId)
				}
			}
		}
	}
}

// MARK: - Recipe Card

struct RecipeCard: View {
	@EnvironmentObject var controller: RecipeController
	let recipe: Recipe

	var body: some View {
		GeometryReader { geo in
			NavigationLink {
				RecipeDetailView(recipe: recipe)
			} label: {
				VStack(alignment: .leading, spacing: 12) {
					// Title
					HStack(alignment: .firstTextBaseline, spacing: 8) {
						Text(recipe.title)
							.font(.title3.weight(.semibold))
							.lineLimit(2)
							.minimumScaleFactor(0.8)
							.foregroundColor(.primary)
							
						Spacer()
							
						Button {
								controller.toggleFavorite(for: recipe.recipeID)
						} label: {
								Image(systemName: recipe.favorited ? "heart.fill" : "heart")
									.foregroundColor(recipe.favorited ? .red : .secondary)
						}
						.buttonStyle(.borderless)
					}
					// Quick facts chips
					HStack(spacing: 8) {
						Chip(icon: "flame.fill", text: "\(recipe.calories) cal").foregroundColor(.primary)
						Chip(icon: "clock.fill", text: "\(recipe.cookMin) min").foregroundColor(.primary)
						Chip(icon: "person.2.fill", text: "Serves \(recipe.servings)").foregroundColor(.primary)
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
				}
				.foregroundStyle(.primary)
				.padding(16)
				.frame(width: min(geo.size.width, 520)) // nice max width for larger devices
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
				.background(
						RoundedRectangle(cornerRadius: 20, style: .continuous)
								.fill(Color(.secondarySystemGroupedBackground))
								.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
				)
				.buttonStyle(.plain)
			}
			.frame(height: 450)
		}
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

#Preview {
	NavigationStack {
		RecipeView(
			ingredients: [
				Ingredient(id: "1", name: "Chicken", quantity: "500", unit: "gram", category: .proteins),
				Ingredient(id: "2", name: "Rice", quantity: "2", unit: "cup", category: .grains)
			],
			scanId: "preview-scan-123"
		)
		.environmentObject(RecipeController(
			geminiService: GeminiService(),
			firestoreService: FirebaseFirestoreService()
		))
	}
}
