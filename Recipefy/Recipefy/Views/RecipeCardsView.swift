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
				ForEach(Array(recipes.enumerated()), id: \.element.recipeID) { index, recipe in
					RecipeCard(recipe: recipe)
						.padding(.horizontal, 16)
						.padding(.vertical, 8)
						.tag(index)
				}
			}
      .tabViewStyle(.page(indexDisplayMode: .automatic))
      .indexViewStyle(.page(backgroundDisplayMode: .always))
			.onChange(of: currentIndex) { newValue in
				guard !recipes.isEmpty else { return }
				if newValue == recipes.count - 1 {
					Task {
						await controller.loadMoreRecipesIfNeeded()
					}
				}
			}
    }
  }
}


