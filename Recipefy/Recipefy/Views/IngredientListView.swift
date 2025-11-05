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
  @State private var showingAddForm = false
  
  var body: some View {
    VStack(spacing: 0) {
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
        .padding()
      }
      
      if let ingredients = controller.currentIngredients {
        List {
          Section {
            ForEach(ingredients) { ingredient in
              HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                  Text(ingredient.name.capitalized)
                    .font(.body)
                    .fontWeight(.medium)
                  HStack(spacing: 8) {
                    Text(ingredient.amount)
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                    Text("•")
                      .font(.caption)
                      .foregroundStyle(.secondary)
                    Text(ingredient.category)
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
              .padding(.vertical, 8)
            }
            .onDelete(perform: deleteIngredients)
          } header: {
            Text("\(ingredients.count) Ingredients Detected")
              .font(.subheadline)
              .textCase(nil)
          }
        }
        .listStyle(.insetGrouped)
      }
    }
    .navigationTitle("Ingredients")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          showingAddForm = true
        }) {
          Image(systemName: "plus")
            .font(.body.weight(.semibold))
        }
      }
    }
    .sheet(isPresented: $showingAddForm) {
      IngredientFormView(controller: controller, scanId: scanId)
    }
    .task {
      if controller.currentIngredients == nil && !controller.isAnalyzing {
        await controller.analyzeIngredients(imageData: imageData, scanId: scanId)
      }
    }
  }
  
  private func deleteIngredients(at offsets: IndexSet) {
    guard let ingredients = controller.currentIngredients else { return }
    
    for index in offsets {
      let ingredient = ingredients[index]
      Task {
        await controller.deleteIngredient(scanId: scanId, ingredient: ingredient)
      }
    }
  }
}
