//
//  IngredientListView.swift
//  Recipefy
//
//  Created by yuqi zou on 10/25/25.
//

import SwiftUI

struct IngredientListView: View {
  let scanId: String
  let imageDataArray: [Data]
  @StateObject private var controller = IngredientController()
  @Environment(\.dismiss) var dismiss
  @State private var showingAddForm = false
  @State private var showingEditForm = false
  @State private var ingredientToEdit: Ingredient?
  
  // Convenience init for single image (backward compatibility)
  init(scanId: String, imageData: Data) {
    self.scanId = scanId
    self.imageDataArray = [imageData]
  }
  
  // Primary init for multiple images
  init(scanId: String, imageDataArray: [Data]) {
    self.scanId = scanId
    self.imageDataArray = imageDataArray
  }
  
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
        VStack(spacing: 0) {
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
                      .font(.caption)
                      .fontWeight(.medium)
                      .foregroundStyle(.secondary)
                      .padding(.horizontal, 8)
                      .padding(.vertical, 4)
                      .background(Color.gray.opacity(0.2))
                      .cornerRadius(6)
                  }
                }
                
                Spacer()
                
                Button(action: {
                  ingredientToEdit = ingredient
                  showingEditForm = true
                }) {
                  Image(systemName: "pencil.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)
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
          
          // Find Recipes Button
          // TODO: Replace Button with NavigationLink when RecipesView is ready
          // NavigationLink(destination: RecipesView(scanId: scanId, ingredients: ingredients)) {
          Button(action: {
            // TODO: Navigate to Recipes view
            print("Find Recipes tapped - scanId: \(scanId), ingredients: \(ingredients.count)")
          }) {
            HStack {
              Image(systemName: "magnifyingglass")
                .font(.title3)
              Text("Find Recipes")
                .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(12)
          }
          .padding()
        }
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
            .foregroundStyle(.green)
        }
      }
    }
    .sheet(isPresented: $showingAddForm) {
      IngredientFormView(controller: controller, scanId: scanId)
    }
    .sheet(isPresented: $showingEditForm) {
      if let ingredient = ingredientToEdit {
        IngredientFormView(controller: controller, scanId: scanId, ingredient: ingredient)
      }
    }
    .task {
      if controller.currentIngredients == nil && !controller.isAnalyzing {
        await controller.analyzeMultipleImages(imageDataArray: imageDataArray, scanId: scanId)
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
