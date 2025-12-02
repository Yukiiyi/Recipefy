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
  @EnvironmentObject var navigationState: NavigationState
  @EnvironmentObject var controller: IngredientController
  @EnvironmentObject var recipeController: RecipeController
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
      // Full-screen loading state when analyzing
      if controller.isAnalyzing {
        VStack(spacing: 20) {
          Spacer()
          
          // Animated icon
          Image(systemName: "sparkle.magnifyingglass")
            .font(.system(size: 56))
            .foregroundStyle(.green)
            .symbolEffect(.pulse)
          
          Text("Finding Ingredients")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
          
          Text(controller.statusText)
            .font(.subheadline)
            .foregroundStyle(.secondary)
          
          ProgressView()
            .scaleEffect(1.2)
            .padding(.top, 8)
          
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if controller.currentIngredients == nil && !controller.statusText.isEmpty {
        // Error or non-analyzing status
        VStack(spacing: 12) {
          Spacer()
          Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 40))
            .foregroundStyle(.orange)
          Text(controller.statusText)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      
      if let ingredients = controller.currentIngredients, !ingredients.isEmpty, !controller.isAnalyzing {
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
                    Text(ingredient.category.rawValue)
                      .font(.caption)
                      .fontWeight(.medium)
                      .foregroundStyle(.secondary)
                      .padding(.horizontal, 8)
                      .padding(.vertical, 4)
                      .background(Color(.systemGray5))
                      .cornerRadius(6)
                  }
                }
                
                Spacer()
                
                Button(action: {
                  ingredientToEdit = ingredient
                  showingEditForm = true
                }) {
                  Image(systemName: "square.and.pencil")
                    .font(.title2)
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
          Button(action: {
            Task {
              // Generate recipes from current ingredients
              await recipeController.getRecipe(ingredients: ingredients, sourceScanId: scanId)
              
              // Switch to Recipes tab to show the generated recipes
              navigationState.navigateToTab(.recipes)
            }
          }) {
            HStack {
              if recipeController.isRetrieving {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
                  .scaleEffect(0.8)
              }
              Image(systemName: "magnifyingglass")
                .font(.title3)
              Text(recipeController.isRetrieving ? "Generating..." : "Find Recipes")
                .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(12)
          }
          .buttonStyle(.plain)
          .disabled(recipeController.isRetrieving)
          .padding()
        }
      }
    }
    .background(Color(.systemGroupedBackground))
    .navigationTitle("Ingredients")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if !recipeController.isRetrieving {
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
    }
    .sheet(isPresented: $showingAddForm) {
      IngredientFormView(controller: controller, scanId: scanId)
    }
    .sheet(isPresented: $showingEditForm) {
      if let ingredient = ingredientToEdit {
        IngredientFormView(controller: controller, scanId: scanId, ingredient: ingredient)
      }
    }
    .task(id: scanId) {
      // Only analyze if scanId changed (new scan with different ingredients)
      if controller.currentScanId != scanId && !controller.isAnalyzing {
        await controller.analyzeMultipleImages(imageDataArray: imageDataArray, scanId: scanId)
      }
    }
    .alert("Error", isPresented: .constant(controller.errorMessage != nil)) {
      Button("OK") {
        controller.errorMessage = nil
      }
    } message: {
      if let errorMessage = controller.errorMessage {
        Text(errorMessage)
      }
    }
    .overlay {
      if recipeController.isRetrieving {
        generatingOverlay
      }
    }
  }
  
  private func deleteIngredients(at offsets: IndexSet) {
    guard let ingredients = controller.currentIngredients else { return }
    
    // Capture ingredients to delete before starting async operations
    let ingredientsToDelete = offsets.map { ingredients[$0] }
    
    // Delete sequentially to avoid race conditions
    Task {
      for ingredient in ingredientsToDelete {
        await controller.deleteIngredient(scanId: scanId, ingredient: ingredient)
      }
    }
  }
  
  // MARK: - Overlays
  private var generatingOverlay: some View {
    ZStack {
      Color.black.opacity(0.6)
        .ignoresSafeArea() // keep tab bar appearance unchanged
      
      VStack(spacing: 14) {
        ProgressView()
          .scaleEffect(1.4)
          .tint(.white)
        Text("Generating recipes...")
          .font(.headline)
          .foregroundStyle(.white)
        Text("This may take up to a minute. Sit tight — we'll show your recipes as soon as they're ready.")
          .font(.subheadline)
          .foregroundStyle(.white.opacity(0.9))
          .multilineTextAlignment(.center)
          .padding(.top, 2)
      }
      .padding(24)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.black.opacity(0.85))
      )
      .padding(.horizontal, 24)
    }
  }
}
