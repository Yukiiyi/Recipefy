//
//  FavoritedRecipeView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/30/25.
//

import SwiftUI

struct FavoritedRecipeView: View {
	@EnvironmentObject var controller: RecipeController

	var body: some View {
		NavigationStack {
			VStack(spacing: 12) {

				if controller.isRetrieving {
					VStack(spacing: 8) {
						ProgressView()
						Text(controller.statusText)
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
					.frame(maxWidth: .infinity, maxHeight: .infinity)

				} else if let recipes = controller.favoritedRecipes, !recipes.isEmpty {
					RecipeCardsView(recipes: recipes)

				} else {
					VStack(spacing: 12) {
						Image(systemName: "heart.slash.fill")
							.font(.system(size: 48))
							.foregroundColor(.accentColor)

						Text("No favorite recipes")
							.font(.headline)

						Text(controller.statusText)
							.font(.subheadline)
							.foregroundColor(.secondary)
					}
					.padding(.top, 40)

					Spacer()
				}
			}
			.padding(.top, 8)
			.task {
				await controller.getFavoriteRecipes()
			}
			.navigationTitle("Favorites")
		}
	}
}
