//
//  IngredientListView.swift
//  Recipefy
//
//  Created by yuqi zou on 10/25/25.
//

import SwiftUI

struct IngredientListView: View {
  let scanId: String
  let imageData: Data
  @StateObject private var controller = IngredientController()
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Only show status when analyzing or there's an error
        if controller.isAnalyzing || (controller.currentIngredients == nil && !controller.statusText.isEmpty) {
          HStack(spacing: 8) {
            if controller.isAnalyzing {
              ProgressView().scaleEffect(0.8)
            }
            Text(controller.statusText).font(.footnote).foregroundStyle(.secondary)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(12)
        }
        
        if let ingredients = controller.currentIngredients {
          VStack(alignment: .leading, spacing: 16) {
            HStack {
              Text("\(ingredients.count) Ingredients Detected").font(.subheadline)
            }
            
            VStack(spacing: 12) {
              ForEach(ingredients.indices, id: \.self) { index in
                HStack(spacing: 12) {
                  VStack(alignment: .leading, spacing: 6) {
                    Text(ingredients[index].name.capitalized)
                      .font(.body)
                      .fontWeight(.medium)
                    HStack(spacing: 8) {
                      Text(ingredients[index].amount)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                      Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                      Text(ingredients[index].category)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    }
                  }
                  
                  Spacer()
                  
                  Button(action: {
                    // TODO: Edit ingredient
                  }) {
                    Image(systemName: "pencil.circle.fill")
                      .font(.title2)
                      .foregroundStyle(.gray)
                  }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
              }
            }
          }
          .padding()
        }
        
        Spacer()
      }
      .padding()
    }
    .navigationTitle("Ingredients")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          // TODO: Add new ingredient
        }) {
          Image(systemName: "plus")
            .font(.body.weight(.semibold))
        }
      }
    }
    .task {
      if controller.currentIngredients == nil && !controller.isAnalyzing {
        await controller.analyzeIngredients(imageData: imageData, scanId: scanId)
      }
    }
  }
}
