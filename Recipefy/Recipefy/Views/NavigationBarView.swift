//
//  NavigationBarView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI

struct NavigationBarView: View {
    @EnvironmentObject var navigationState: NavigationState
    @EnvironmentObject var scanController: ScanController
    @EnvironmentObject var ingredientController: IngredientController
    @EnvironmentObject var recipeController: RecipeController
    
    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
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
                if let scanId = scanController.currentScanId {
                    // Show IngredientListView if we have a scan
                    // Use image data if available (fresh scan), otherwise empty array (loaded from DB)
                    let imageData = scanController.currentImageData ?? []
                    IngredientListView(
                        scanId: scanId,
                        imageDataArray: imageData
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
                // Only load from DB if we don't have a fresh scan with image data
                // like if user manually opened this tab without going through the scan flow
                if let scanId = scanController.currentScanId,
                   scanController.currentImageData == nil,
                   !ingredientController.isAnalyzing {
                    // Load from DB only if we don't have ingredients for this scan
                    if ingredientController.currentIngredients == nil || 
                       ingredientController.currentScanId != scanId {
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
						// Show recipe cards via shared view
						RecipeCardsView(recipes: recipes)
                        .padding(.top, 8)
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
        .environmentObject(NavigationState())
        .environmentObject(AuthController())
        .environmentObject(ScanController(storage: FirebaseStorageService(), scans: FirebaseScanRepository()))
        .environmentObject(IngredientController())
        .environmentObject(RecipeController())
}

