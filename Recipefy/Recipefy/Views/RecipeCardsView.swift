//
//  RecipeCardsView.swift
//  Recipefy
//
//  Created by streak honey on 11/13/25.
//

import SwiftUI

struct RecipeCardsView: View {
	@EnvironmentObject var controller: RecipeController
	let recipes: [Recipe]
	@State private var currentIndex: Int = 0
  
	var body: some View {
		VStack(spacing: 12) {
			// Header with count
			HStack {
				Text("Recipe Suggestions")
					.font(.title2).bold()
				Spacer()
				Text("\(recipes.count)")
					.font(.subheadline.monospacedDigit())
					.foregroundColor(.secondary)
			}
			.padding(.horizontal, 16)
      
			TabView(selection: $currentIndex) {
				// Recipe cards
				ForEach(Array(recipes.enumerated()), id: \.element.recipeID) { index, recipe in
					RecipeCard(recipe: recipe)
						.padding(.horizontal, 16)
						.padding(.vertical, 8)
						.tag(index)
				}
				
				// "Generate More" card at the end (only if ingredients are available)
				if controller.canGenerateMore {
					GenerateMoreCard()
						.padding(.horizontal, 16)
						.padding(.vertical, 8)
						.tag(recipes.count)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .automatic))
			.indexViewStyle(.page(backgroundDisplayMode: .always))
		}
	}
}

// MARK: - Generate More Card

struct GenerateMoreCard: View {
	@EnvironmentObject var controller: RecipeController
	
	var body: some View {
		VStack(spacing: 20) {
			Spacer()
			
			if controller.isLoadingMore {
				VStack(spacing: 16) {
					ProgressView()
						.scaleEffect(1.5)
					Text("Generating more recipes...")
						.font(.headline)
						.foregroundColor(.secondary)
				}
			} else {
				Image(systemName: "sparkles")
					.font(.system(size: 56))
					.foregroundColor(.accentColor)
				
				Text("Want more ideas?")
					.font(.title2.bold())
				
				Text("Generate additional recipe suggestions based on your ingredients")
					.font(.subheadline)
					.foregroundColor(.secondary)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 24)
				
				Button {
					Task {
						await controller.loadMoreRecipesIfNeeded()
					}
				} label: {
					HStack {
						Image(systemName: "plus.circle.fill")
						Text("Generate More Recipes")
					}
					.font(.headline)
					.padding(.horizontal, 24)
					.padding(.vertical, 14)
				}
				.buttonStyle(.borderedProminent)
				.padding(.top, 8)
			}
			
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(
			RoundedRectangle(cornerRadius: 20, style: .continuous)
				.fill(Color(.secondarySystemGroupedBackground))
				.shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
		)
	}
}


