//
//  FavoriteRecipesView.swift
//  Recipefy
//
//  Created by Jonass Oh on 12/3/25.
//

import SwiftUI

struct FavoriteRecipesView: View {
	@EnvironmentObject var controller: RecipeController
	
	var body: some View {
		VStack(spacing: 12) {
			if controller.isRetrieving {
				VStack(spacing: 8) {
					ProgressView()
					Text(controller.statusText)
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			} else if let recipes = controller.favoriteRecipes, !recipes.isEmpty {
				// Reuse the same cards view
				RecipeCardsView(recipes: recipes)
			} else {
				// Empty state
				VStack(spacing: 12) {
					Image(systemName: "heart.circle.fill")
						.font(.system(size: 48))
						.foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
					Text("No favorite recipes yet")
						.font(.headline)
					Text(controller.statusText)
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
				.padding(.top, 40)
				Spacer()
			}
		}
		.navigationTitle("Favorites")
		.animation(.easeInOut, value: controller.favoriteRecipes?.count ?? 0)
		.padding(.top, 8)
		.task {
			if !controller.isRetrieving {
				await controller.loadFavoriteRecipes()
			}
		}
	}
}
