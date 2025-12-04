//
//  DietaryPreferences.swift
//  Recipefy
//
//  Created on 12/2/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Diet Types
enum DietType: String, CaseIterable, Codable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case pescatarian = "Pescatarian"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case lowCarb = "Low-Carb"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .vegetarian: return "leaf.fill"
        case .vegan: return "leaf.circle.fill"
        case .pescatarian: return "fish.fill"
        case .glutenFree: return "allergens"
        case .dairyFree: return "drop.fill"
        case .lowCarb: return "flame.fill"
        }
    }
    
    var description: String {
        switch self {
        case .vegetarian: return "No meat or fish"
        case .vegan: return "No animal products"
        case .pescatarian: return "No meat (fish OK)"
        case .glutenFree: return "No wheat, barley, rye"
        case .dairyFree: return "No milk products"
        case .lowCarb: return "Reduced carbohydrates"
        }
    }
}

// MARK: - Allergy Types
enum AllergyType: String, CaseIterable, Codable {
    case peanuts = "Peanuts"
    case treeNuts = "Tree Nuts"
    case shellfish = "Shellfish"
    case fish = "Fish"
    case eggs = "Eggs"
    case dairy = "Dairy"
    case gluten = "Gluten"
    case soy = "Soy"
    case sesame = "Sesame"
    
    var icon: String {
        switch self {
        case .peanuts: return "circle.fill"
        case .treeNuts: return "leaf.fill"
        case .shellfish: return "water.waves"
        case .fish: return "fish.fill"
        case .eggs: return "circle.grid.2x2.fill"
        case .dairy: return "drop.fill"
        case .gluten: return "allergens"
        case .soy: return "leaf.circle.fill"
        case .sesame: return "circle.dotted"
        }
    }
}

// MARK: - Dietary Preferences Model
struct DietaryPreferences: Codable {
    var dietTypes: [DietType]  // Changed to array for multi-select
    var allergies: [AllergyType]
    var dislikes: [String]
    var maxCookingTime: Int  // in minutes
    
    init(
        dietTypes: [DietType] = [],
        allergies: [AllergyType] = [],
        dislikes: [String] = [],
        maxCookingTime: Int = 60
    ) {
        self.dietTypes = dietTypes
        self.allergies = allergies
        self.dislikes = dislikes
        self.maxCookingTime = maxCookingTime
    }
    
    // Convert to Firestore dictionary
    func toFirestore() -> [String: Any] {
        return [
            "dietTypes": dietTypes.map { $0.rawValue },
            "allergies": allergies.map { $0.rawValue },
            "dislikes": dislikes,
            "maxCookingTime": maxCookingTime,
            "updatedAt": Timestamp(date: Date())
        ]
    }
    
    // Create from Firestore data
    static func fromFirestore(_ data: [String: Any]) -> DietaryPreferences? {
        guard let dietTypesStrings = data["dietTypes"] as? [String],
              let allergiesStrings = data["allergies"] as? [String],
              let dislikes = data["dislikes"] as? [String],
              let maxCookingTime = data["maxCookingTime"] as? Int else {
            return nil
        }
        
        let dietTypes = dietTypesStrings.compactMap { DietType(rawValue: $0) }
        let allergies = allergiesStrings.compactMap { AllergyType(rawValue: $0) }
        
        return DietaryPreferences(
            dietTypes: dietTypes,
            allergies: allergies,
            dislikes: dislikes,
            maxCookingTime: maxCookingTime
        )
    }
    
    // Generate AI prompt section
    func toPromptString() -> String {
        var prompt = "\n\nUSER DIETARY PREFERENCES:\n"
        
        // Diet types (multi-select)
        if !dietTypes.isEmpty {
            let dietList = dietTypes.map { "\($0.displayName) (\($0.description))" }.joined(separator: ", ")
            prompt += "- Diet Types: \(dietList)\n"
        }
        
        // Allergies (critical)
        if !allergies.isEmpty {
            let allergyList = allergies.map { $0.rawValue }.joined(separator: ", ")
            prompt += "- ALLERGIES (CRITICAL - MUST AVOID): \(allergyList)\n"
        }
        
        // Dislikes
        if !dislikes.isEmpty {
            let dislikeList = dislikes.joined(separator: ", ")
            prompt += "- Dislikes (avoid if possible): \(dislikeList)\n"
        }
        
        // Max cooking time
        prompt += "- Maximum Cooking Time: \(maxCookingTime) minutes\n"
        
        prompt += "\nIMPORTANT: Generate recipes that strictly respect these dietary constraints, especially allergies.\n"
        
        return prompt
    }
}

