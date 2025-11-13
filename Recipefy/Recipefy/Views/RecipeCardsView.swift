//
//  RecipeCardsView.swift
//  Recipefy
//
//  Created by streak honey on 11/13/25.
//

import SwiftUI

struct RecipeCardsView: View {
  let recipes: [Recipe]
  
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
      
      TabView {
        ForEach(recipes, id: \.recipeID) { recipe in
          RecipeCard(recipe: recipe)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .automatic))
      .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
  }
}


