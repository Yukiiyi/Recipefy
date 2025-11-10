//
//  NavigationBarView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI

struct NavigationBarView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var scanController: ScanController
    @EnvironmentObject var ingredientController: IngredientController
    @EnvironmentObject var recipeController: RecipeController
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tab 2: Ingredients
            NavigationStack {
                if let ingredients = ingredientController.currentIngredients,
                   !ingredients.isEmpty,
                   let scanId = scanController.currentScanId {
                    IngredientListView(
                        scanId: scanId,
                        imageDataArray: scanController.currentImageData ?? []
                    )
                    .navigationTitle("My Ingredients")
                } else {
                    EmptyStateView(
                        icon: "camera.fill",
                        title: "No Ingredients Yet",
                        message: "Scan ingredients to get started",
                        buttonText: nil,
                        buttonAction: nil
                    )
                    .navigationTitle("My Ingredients")
                }
            }
            .task {
                // Load ingredients from Firestore only if needed
                // Don't load if we already have ingredients for this scan
                if let scanId = scanController.currentScanId {
                    let needsLoad = ingredientController.currentIngredients == nil || 
                                    ingredientController.currentScanId != scanId
                    
                    if needsLoad && !ingredientController.isAnalyzing {
                        await ingredientController.loadIngredients(scanId: scanId)
                    }
                }
            }
            .tabItem {
                Label("Ingredients", systemImage: "list.bullet")
            }
            .tag(1)
            
            // Tab 3: Scan (Main Action)
            NavigationStack {
                ScanView(controller: scanController)
            }
            .tabItem {
                Label("Scan", systemImage: "camera.fill")
            }
            .tag(2)
            
            // Tab 4: Recipes
            NavigationStack {
                Group {
                    if recipeController.isRetrieving {
                        VStack {
                            ProgressView()
                            Text("Loading recipes...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationTitle("Recipes")
                    } else if let recipes = recipeController.currentRecipes, !recipes.isEmpty {
                        // Show recipe cards
                        VStack(spacing: 12) {
                            Text("Your Recipes")
                                .font(.title2).bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
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
                        .navigationTitle("Recipes")
                    } else {
                        EmptyStateView(
                            icon: "fork.knife",
                            title: "No Recipes Yet",
                            message: "Scan ingredients and generate recipes to get started",
                            buttonText: nil,
                            buttonAction: nil
                        )
                        .navigationTitle("Recipes")
                    }
                }
                .task {
                    // Load recipes from Firestore when tab appears (only if empty)
                    if recipeController.currentRecipes == nil && !recipeController.isRetrieving {
                        await recipeController.loadRecipes()
                    }
                }
            }
            .tabItem {
                Label("Recipes", systemImage: "fork.knife")
            }
            .tag(3)
            
            // Tab 5: Settings
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .accentColor(Color(red: 0.36, green: 0.72, blue: 0.36)) // Recipefy green
    }
}

#Preview {
    NavigationBarView()
        .environmentObject(AuthController())
        .environmentObject(ScanController(storage: FirebaseStorageService(), scans: FirebaseScanRepository()))
        .environmentObject(IngredientController())
        .environmentObject(RecipeController())
}

