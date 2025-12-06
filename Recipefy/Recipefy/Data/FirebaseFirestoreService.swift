//
//  FirebaseFirestoreService.swift
//  Recipefy
//
//  Concrete implementation of FirestoreServiceProtocol using Firebase
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseFirestoreService: FirestoreServiceProtocol {
  private let db = Firestore.firestore()
  
  // MARK: - Ingredient Operations
  
  func saveIngredients(scanId: String, ingredients: [Ingredient]) async throws -> [Ingredient] {
    var ingredientsWithIds = ingredients
    let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
    let batch = db.batch()
    
    // Create document references and add to batch
    for (index, ingredient) in ingredientsWithIds.enumerated() {
      let docRef = ingredientsCollection.document()
      ingredientsWithIds[index].id = docRef.documentID
      
      let ingredientData: [String: Any] = [
        "name": ingredient.name,
        "quantity": ingredient.quantity,
        "unit": ingredient.unit,
        "category": ingredient.category.rawValue,
        "createdAt": Timestamp(date: Date())
      ]
      
      batch.setData(ingredientData, forDocument: docRef)
    }
    
    try await batch.commit()
    return ingredientsWithIds
  }
  
  func loadIngredients(scanId: String) async throws -> [Ingredient] {
    let snapshot = try await db.collection("scans")
      .document(scanId)
      .collection("ingredients")
      .getDocuments()
    
    return snapshot.documents.compactMap { doc -> Ingredient? in
      let data = doc.data()
      
      guard let name = data["name"] as? String,
            let quantity = data["quantity"] as? String,
            let unit = data["unit"] as? String,
            let categoryString = data["category"] as? String
      else {
        return nil
      }
      
      let category = IngredientCategory.from(string: categoryString)
      return Ingredient(id: doc.documentID, name: name, quantity: quantity, unit: unit, category: category)
    }
  }
  
  func deleteIngredient(scanId: String, ingredientId: String) async throws {
    try await db.collection("scans")
      .document(scanId)
      .collection("ingredients")
      .document(ingredientId)
      .delete()
  }
  
  func addIngredient(scanId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws -> Ingredient {
    let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
    
    let ingredientData: [String: Any] = [
      "name": name,
      "quantity": quantity,
      "unit": unit,
      "category": category.rawValue,
      "createdAt": Timestamp(date: Date())
    ]
    
    let docRef = try await ingredientsCollection.addDocument(data: ingredientData)
    return Ingredient(id: docRef.documentID, name: name, quantity: quantity, unit: unit, category: category)
  }
  
  func updateIngredient(scanId: String, ingredientId: String, name: String, quantity: String, unit: String, category: IngredientCategory) async throws {
    let ingredientsCollection = db.collection("scans").document(scanId).collection("ingredients")
    
    let ingredientData: [String: Any] = [
      "name": name,
      "quantity": quantity,
      "unit": unit,
      "category": category.rawValue
    ]
    
    try await ingredientsCollection.document(ingredientId).setData(ingredientData, merge: true)
  }
  
  // MARK: - Recipe Operations
  
  func saveRecipes(userId: String, recipes: [Recipe], sourceScanId: String?) async throws {
    for recipe in recipes {
      let recipeData: [String: Any] = [
        "title": recipe.title,
        "description": recipe.description,
        "ingredients": recipe.ingredients,
        "steps": recipe.steps,
        "calories": recipe.calories,
        "servings": recipe.servings,
        "cookMin": recipe.cookMin,
        "protein": recipe.protein,
        "carbs": recipe.carbs,
        "fat": recipe.fat,
        "fiber": recipe.fiber,
        "sugar": recipe.sugar,
        "createdBy": userId,
        "sourceScanId": sourceScanId ?? "",
        "favorited": recipe.favorited,
        "createdAt": Timestamp(date: Date())
      ]
      
      try await db.collection("recipes").addDocument(data: recipeData)
    }
  }
  
  func loadRecipes(userId: String) async throws -> (recipes: [Recipe], scanId: String?) {
    // Step 1: Get the most recent recipe to find the latest scan
    let recentSnapshot = try await db.collection("recipes")
      .whereField("createdBy", isEqualTo: userId)
      .order(by: "createdAt", descending: true)
      .limit(to: 1)
      .getDocuments()
    
    guard let mostRecentDoc = recentSnapshot.documents.first,
          let mostRecentScanId = mostRecentDoc.data()["sourceScanId"] as? String,
          !mostRecentScanId.isEmpty else {
      return ([], nil)
    }
    
    // Step 2: Get all recipes from that scan
    let snapshot = try await db.collection("recipes")
      .whereField("createdBy", isEqualTo: userId)
      .whereField("sourceScanId", isEqualTo: mostRecentScanId)
      .order(by: "createdAt", descending: false)
      .getDocuments()
    
    let recipes = snapshot.documents.compactMap { doc -> Recipe? in
      parseRecipeFromDocument(doc)
    }
    
    return (recipes, mostRecentScanId)
  }
  
  func loadFavoriteRecipes(userId: String) async throws -> [Recipe] {
    let snapshot = try await db.collection("recipes")
      .whereField("createdBy", isEqualTo: userId)
      .whereField("favorited", isEqualTo: true)
      .order(by: "createdAt", descending: true)
      .getDocuments()
    
    return snapshot.documents.compactMap { doc -> Recipe? in
      parseRecipeFromDocument(doc)
    }
  }
  
  func updateRecipeFavorite(recipeId: String, isFavorited: Bool) async throws {
    try await db.collection("recipes")
      .document(recipeId)
      .updateData(["favorited": isFavorited])
  }
  
  // MARK: - Dietary Preferences Operations
  
  func loadDietaryPreferences(userId: String) async throws -> DietaryPreferences? {
    let document = try await db.collection("users")
      .document(userId)
      .collection("preferences")
      .document("dietary")
      .getDocument()
    
    guard let data = document.data() else {
      return nil
    }
    
    return DietaryPreferences.fromFirestore(data)
  }
  
  func saveDietaryPreferences(userId: String, preferences: DietaryPreferences) async throws {
    try await db.collection("users")
      .document(userId)
      .collection("preferences")
      .document("dietary")
      .setData(preferences.toFirestore(), merge: true)
  }
  
  // MARK: - Helper Methods
  
  private func parseRecipeFromDocument(_ doc: QueryDocumentSnapshot) -> Recipe? {
    let data = doc.data()
    
    guard let title = data["title"] as? String,
          let description = data["description"] as? String,
          let ingredients = data["ingredients"] as? [String],
          let steps = data["steps"] as? [String],
          let calories = data["calories"] as? Int,
          let servings = data["servings"] as? Int,
          let cookMin = data["cookMin"] as? Int,
          let protein = data["protein"] as? Int,
          let carbs = data["carbs"] as? Int,
          let fat = data["fat"] as? Int,
          let fiber = data["fiber"] as? Int
    else {
      return nil
    }
    
    let sugar = data["sugar"] as? Int ?? 0
    let favorited = data["favorited"] as? Bool ?? false
    
    return Recipe(
      recipeID: doc.documentID,
      title: title,
      description: description,
      ingredients: ingredients,
      steps: steps,
      calories: calories,
      servings: servings,
      cookMin: cookMin,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      favorited: favorited
    )
  }
}

