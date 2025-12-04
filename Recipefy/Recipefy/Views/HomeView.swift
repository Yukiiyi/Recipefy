//
//  HomeView.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/05/25.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    ZStack {
      // Background that extends to edges
      Color(.systemGroupedBackground)
        .ignoresSafeArea(.all)
      
      ScrollView {
        VStack(spacing: 24) {
          // Welcome Header - with safe area top padding
          Text("Welcome Back!")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top)
          
          // Green Call-to-Action Card
          VStack(alignment: .leading, spacing: 12) {
            Text("Fresh Ingredients?")
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.white)
            
            Text("Scan to get instant recipe ideas")
              .font(.system(size: 16, weight: .regular))
              .foregroundColor(.white.opacity(0.9))
            
          Button {
            // Switch to Scan tab
            navigationState.navigateToTab(.scan)
          } label: {
              HStack(spacing: 8) {
                Image(systemName: "camera.fill")
                  .font(.system(size: 16, weight: .semibold))
                Text("Start Scanning")
                  .font(.system(size: 16, weight: .semibold))
              }
              .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .background(Color(.systemBackground))
              .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
          }
          .padding(20)
          .frame(maxWidth: .infinity)
          .background(Color(red: 0.36, green: 0.72, blue: 0.36))
          .cornerRadius(20)
          .padding(.horizontal)
          .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
          
          // Quick Actions Section
          VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(.primary)
              .padding(.horizontal)
            
          // My Ingredients Row
          NavigationLink(destination: MyIngredientsRouteView()) {
            QuickActionRow(
              icon: "list.bullet.rectangle",
              title: "My Ingredients",
              subtitle: "View and Manage your Pantry"
            )
          }
          .buttonStyle(.plain)
            
          // Saved Recipes Row
          NavigationLink(destination: FavoriteRecipesView()) {
            QuickActionRow(
              icon: "heart.fill",
              title: "Saved Recipes",
              subtitle: "Your Favorite Recipes"
            )
          }
          .buttonStyle(.plain)
            
          // Browse Recipes Row
          NavigationLink(destination: BrowseRecipesRouteView()) {
            QuickActionRow(
              icon: "fork.knife",
              title: "Browse Recipes",
              subtitle: "Explore new Recipe"
            )
          }
          .buttonStyle(.plain)
          }
          .padding(.top, 8)
          
          // Bottom padding to account for safe area
          Spacer()
            .frame(height: 20)
        }
      }
    }
    .navigationBarHidden(true)
  }
}

struct QuickActionRow: View {
  let icon: String
  let title: String
  let subtitle: String
  
  var body: some View {
    HStack(spacing: 16) {
      // Icon with circular background
      ZStack {
        Circle()
          .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.15))
          .frame(width: 50, height: 50)
        
        Image(systemName: icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
      }
      
      // Text content
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 17, weight: .bold))
          .foregroundColor(.primary)
        
        Text(subtitle)
          .font(.system(size: 14, weight: .regular))
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      // Chevron
      Image(systemName: "chevron.right")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
    }
    .padding(.horizontal)
    .padding(.vertical, 14)
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
    .padding(.horizontal)
    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

#Preview {
  HomeView()
}

// MARK: - Inline placeholder screens (kept private to this file)

// Route view for My Ingredients that uses shared controllers from environment
private struct MyIngredientsRouteView: View {
  @EnvironmentObject var scanController: ScanController
  @EnvironmentObject var ingredientController: IngredientController
  
  var body: some View {
    Group {
      if let ingredients = ingredientController.currentIngredients,
         !ingredients.isEmpty,
         let scanId = scanController.currentScanId {
        IngredientListView(
          scanId: scanId,
          imageDataArray: scanController.currentImageData ?? []
        )
      } else {
        EmptyStateView(
          icon: "camera.fill",
          title: "No Ingredients Yet",
          message: "Scan ingredients to get started",
          buttonText: nil,
          buttonAction: nil
        )
      }
    }
    .navigationTitle("My Ingredients")
    .task {
      // Load ingredients from Firestore if needed
      if let scanId = scanController.currentScanId {
        let needsLoad = ingredientController.currentIngredients == nil || 
                        ingredientController.currentScanId != scanId
        
        if needsLoad && !ingredientController.isAnalyzing {
          await ingredientController.loadIngredients(scanId: scanId)
        }
      }
    }
  }
}

// Route view for Browse Recipes that uses shared controller from environment
private struct BrowseRecipesRouteView: View {
  @EnvironmentObject var recipeController: RecipeController
  
  var body: some View {
    Group {
      if recipeController.isRetrieving {
        VStack {
          ProgressView()
          Text("Loading recipes...")
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let recipes = recipeController.currentRecipes, !recipes.isEmpty {
        // Show recipe cards
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
        .padding(.top, 8)
      } else {
        EmptyStateView(
          icon: "fork.knife",
          title: "No Recipes Yet",
          message: "Generate recipes from your scanned ingredients",
          buttonText: nil,
          buttonAction: nil
        )
      }
    }
    .navigationTitle("Recipes")
    .task {
      // Load recipes from Firestore if needed
      if recipeController.currentRecipes == nil && !recipeController.isRetrieving {
        await recipeController.loadRecipes()
      }
    }
  }
}
