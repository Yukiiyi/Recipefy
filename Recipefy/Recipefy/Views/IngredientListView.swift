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
          
          Text("Identifying Ingredients")
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
      
      // Empty state when all ingredients have been deleted
      if let ingredients = controller.currentIngredients, ingredients.isEmpty, !controller.isAnalyzing {
        VStack(spacing: 16) {
          Spacer()
          
          Image(systemName: "basket")
            .font(.system(size: 48))
            .foregroundStyle(.green)
          
          Text("No Ingredients")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
          
          Text("Tap + to add ingredients manually\nor scan new items")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
          
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      
      if let ingredients = controller.currentIngredients, !ingredients.isEmpty, !controller.isAnalyzing {
        VStack(spacing: 0) {
          // Compact summary at top - aligned with list content
          Text("\(ingredients.count) ingredients detected")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 32)
            .padding(.trailing, 20)
            .padding(.top, 8)
            .padding(.bottom, 4)
          
          List {
            // Group by category
            ForEach(IngredientCategory.allCases, id: \.self) { category in
              let categoryIngredients = ingredients.filter { $0.category == category }
              
              if !categoryIngredients.isEmpty {
                Section {
                  ForEach(categoryIngredients) { ingredient in
                    HStack(spacing: 12) {
                      VStack(alignment: .leading, spacing: 4) {
                        Text(ingredient.name.capitalized)
                          .font(.body)
                          .fontWeight(.medium)
                        Text(ingredient.amount)
                          .font(.subheadline)
                          .foregroundStyle(.secondary)
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
                    .padding(.vertical, 4)
                  }
                  .onDelete { indexSet in
                    deleteIngredientsFromCategory(categoryIngredients, at: indexSet)
                  }
                } header: {
                  HStack(spacing: 6) {
                    Image(systemName: categoryIcon(for: category))
                      .foregroundStyle(.green)
                    Text(category.rawValue)
                  }
                  .font(.subheadline.weight(.semibold))
                  .textCase(nil)
                }
              }
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
      // Dietary preferences button (top-left)
      if !recipeController.isRetrieving {
        ToolbarItem(placement: .navigationBarLeading) {
          NavigationLink(destination: PreferencesView()) {
            Image(systemName: "leaf.fill")
              .font(.body.weight(.semibold))
              .foregroundStyle(.green)
          }
        }
      }
      
      // Add ingredient button (top-right)
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
  
  private func deleteIngredientsFromCategory(_ categoryIngredients: [Ingredient], at offsets: IndexSet) {
    // Get the ingredients to delete from the filtered category list
    let ingredientsToDelete = offsets.map { categoryIngredients[$0] }
    
    Task {
      for ingredient in ingredientsToDelete {
        await controller.deleteIngredient(scanId: scanId, ingredient: ingredient)
      }
    }
  }
  
  private func categoryIcon(for category: IngredientCategory) -> String {
    switch category {
    case .vegetables: return "carrot.fill"
    case .proteins: return "fish.fill"
    case .grains: return "laurel.leading"
    case .dairy: return "cup.and.saucer.fill"
    case .seasonings: return "leaf.fill"
    case .oil: return "drop.fill"
    case .other: return "ellipsis.circle.fill"
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

#Preview {
  let navigationState = NavigationState()
  let ingredientController = IngredientController(
    geminiService: GeminiService(),
    firestoreService: FirebaseFirestoreService()
  )
  let recipeController = RecipeController(
    geminiService: GeminiService(),
    firestoreService: FirebaseFirestoreService()
  )
  
  // Set mock ingredients
  ingredientController.currentIngredients = [
    Ingredient(id: "1", name: "Chicken Breast", quantity: "2", unit: "lb", category: .proteins),
    Ingredient(id: "2", name: "Broccoli", quantity: "1", unit: "bunch", category: .vegetables),
    Ingredient(id: "3", name: "Rice", quantity: "2", unit: "cup", category: .grains),
    Ingredient(id: "4", name: "Olive Oil", quantity: "2", unit: "tbsp", category: .oil)
  ]
  ingredientController.currentScanId = "preview-scan-123"
  
  return NavigationStack {
    IngredientListView(
      scanId: "preview-scan-123",
      imageDataArray: []
    )
    .environmentObject(navigationState)
    .environmentObject(ingredientController)
    .environmentObject(recipeController)
  }
}
