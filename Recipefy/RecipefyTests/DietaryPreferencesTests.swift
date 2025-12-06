//
//  DietaryPreferencesTests.swift
//  RecipefyTests
//
//  Tests for the DietaryPreferences model
//

import Testing
import Foundation
import FirebaseFirestore
@testable import Recipefy

@MainActor
struct DietaryPreferencesTests {
    
    // MARK: - Initialization Tests
    
    @Test("DietaryPreferences initializes with default values")
    func dietaryPreferences_init_defaults() async throws {
        let prefs = DietaryPreferences()
        
        #expect(prefs.dietTypes.isEmpty)
        #expect(prefs.allergies.isEmpty)
        #expect(prefs.dislikes.isEmpty)
        #expect(prefs.maxCookingTime == 60)
    }
    
    @Test("DietaryPreferences initializes with custom values")
    func dietaryPreferences_init_customValues() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [.vegetarian, .glutenFree],
            allergies: [.peanuts, .shellfish],
            dislikes: ["cilantro", "olives"],
            maxCookingTime: 45
        )
        
        #expect(prefs.dietTypes.count == 2)
        #expect(prefs.dietTypes.contains(.vegetarian))
        #expect(prefs.dietTypes.contains(.glutenFree))
        #expect(prefs.allergies.contains(.peanuts))
        #expect(prefs.dislikes.contains("cilantro"))
        #expect(prefs.maxCookingTime == 45)
    }
    
    // MARK: - Firestore Conversion Tests
    
    @Test("toFirestore converts to correct dictionary format")
    func toFirestore_convertsCorrectly() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [.vegetarian, .vegan],
            allergies: [.peanuts],
            dislikes: ["mushrooms"],
            maxCookingTime: 30
        )
        
        let dict = prefs.toFirestore()
        
        #expect(dict["dietTypes"] as? [String] == ["Vegetarian", "Vegan"])
        #expect(dict["allergies"] as? [String] == ["Peanuts"])
        #expect(dict["dislikes"] as? [String] == ["mushrooms"])
        #expect(dict["maxCookingTime"] as? Int == 30)
        #expect(dict["updatedAt"] is Timestamp)
    }
    
    @Test("fromFirestore creates correct object from dictionary")
    func fromFirestore_createsCorrectObject() async throws {
        let dict: [String: Any] = [
            "dietTypes": ["Vegetarian", "Gluten-Free"],
            "allergies": ["Peanuts", "Shellfish"],
            "dislikes": ["cilantro", "olives"],
            "maxCookingTime": 45,
            "updatedAt": Timestamp(date: Date())
        ]
        
        let prefs = DietaryPreferences.fromFirestore(dict)
        
        #expect(prefs != nil)
        #expect(prefs?.dietTypes.count == 2)
        #expect(prefs?.dietTypes.contains(.vegetarian) == true)
        #expect(prefs?.dietTypes.contains(.glutenFree) == true)
        #expect(prefs?.allergies.contains(.peanuts) == true)
        #expect(prefs?.dislikes.contains("cilantro") == true)
        #expect(prefs?.maxCookingTime == 45)
    }
    
    @Test("fromFirestore returns nil for invalid data")
    func fromFirestore_returnsNilForInvalidData() async throws {
        let invalidDict: [String: Any] = [
            "dietTypes": "not an array",  // Should be array
            "allergies": ["Peanuts"],
            "dislikes": ["cilantro"],
            "maxCookingTime": 45
        ]
        
        let prefs = DietaryPreferences.fromFirestore(invalidDict)
        
        #expect(prefs == nil)
    }
    
    @Test("fromFirestore returns nil for missing required fields")
    func fromFirestore_returnsNilForMissingFields() async throws {
        let incompleteDict: [String: Any] = [
            "dietTypes": ["Vegetarian"],
            // Missing allergies, dislikes, maxCookingTime
        ]
        
        let prefs = DietaryPreferences.fromFirestore(incompleteDict)
        
        #expect(prefs == nil)
    }
    
    // MARK: - Prompt String Tests
    
    @Test("toPromptString formats diet types correctly")
    func toPromptString_formatsDietTypes() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [.vegetarian],
            allergies: [],
            dislikes: [],
            maxCookingTime: 60
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("Diet Types: Vegetarian"))
        #expect(prompt.contains("No meat or fish"))
    }
    
    @Test("toPromptString formats allergies as critical")
    func toPromptString_formatsAllergiesAsCritical() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [],
            allergies: [.peanuts, .shellfish],
            dislikes: [],
            maxCookingTime: 60
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("ALLERGIES (CRITICAL - MUST AVOID)"))
        #expect(prompt.contains("Peanuts"))
        #expect(prompt.contains("Shellfish"))
    }
    
    @Test("toPromptString formats dislikes correctly")
    func toPromptString_formatsDislikes() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [],
            allergies: [],
            dislikes: ["cilantro", "mushrooms"],
            maxCookingTime: 60
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("Dislikes (avoid if possible)"))
        #expect(prompt.contains("cilantro"))
        #expect(prompt.contains("mushrooms"))
    }
    
    @Test("toPromptString includes cooking time")
    func toPromptString_includesCookingTime() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [],
            allergies: [],
            dislikes: [],
            maxCookingTime: 30
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("Maximum Cooking Time: 30 minutes"))
    }
    
    @Test("toPromptString includes important instruction")
    func toPromptString_includesImportantInstruction() async throws {
        let prefs = DietaryPreferences()
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("IMPORTANT: Generate recipes that strictly respect these dietary constraints"))
    }
    
    @Test("toPromptString handles multiple diet types")
    func toPromptString_handlesMultipleDietTypes() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [.vegetarian, .glutenFree, .dairyFree],
            allergies: [],
            dislikes: [],
            maxCookingTime: 60
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("Vegetarian"))
        #expect(prompt.contains("Gluten-Free"))
        #expect(prompt.contains("Dairy-Free"))
    }
    
    @Test("toPromptString omits empty sections")
    func toPromptString_omitsEmptySections() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [.vegan],
            allergies: [],  // Empty
            dislikes: [],   // Empty
            maxCookingTime: 60
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(!prompt.contains("ALLERGIES"))
        #expect(!prompt.contains("Dislikes"))
        #expect(prompt.contains("Diet Types: Vegan"))
    }
    
    // MARK: - DietType Enum Tests
    
    @Test("DietType displays correct names")
    func dietType_displayNames_correct() async throws {
        #expect(DietType.vegetarian.displayName == "Vegetarian")
        #expect(DietType.vegan.displayName == "Vegan")
        #expect(DietType.pescatarian.displayName == "Pescatarian")
        #expect(DietType.glutenFree.displayName == "Gluten-Free")
        #expect(DietType.dairyFree.displayName == "Dairy-Free")
        #expect(DietType.lowCarb.displayName == "Low-Carb")
    }
    
    @Test("DietType has correct descriptions")
    func dietType_descriptions_correct() async throws {
        #expect(DietType.vegetarian.description == "No meat or fish")
        #expect(DietType.vegan.description == "No animal products")
        #expect(DietType.glutenFree.description == "No wheat, barley, rye")
    }
    
    @Test("DietType has icons")
    func dietType_hasIcons() async throws {
        #expect(!DietType.vegetarian.icon.isEmpty)
        #expect(!DietType.vegan.icon.isEmpty)
        #expect(!DietType.pescatarian.icon.isEmpty)
    }
    
    // MARK: - AllergyType Enum Tests
    
    @Test("AllergyType rawValues are correct")
    func allergyType_rawValues_correct() async throws {
        #expect(AllergyType.peanuts.rawValue == "Peanuts")
        #expect(AllergyType.shellfish.rawValue == "Shellfish")
        #expect(AllergyType.gluten.rawValue == "Gluten")
    }
    
    @Test("AllergyType has icons")
    func allergyType_hasIcons() async throws {
        #expect(!AllergyType.peanuts.icon.isEmpty)
        #expect(!AllergyType.shellfish.icon.isEmpty)
        #expect(!AllergyType.dairy.icon.isEmpty)
    }
    
    @Test("All AllergyType cases are defined")
    func allergyType_allCases_complete() async throws {
        let allCases = AllergyType.allCases
        
        #expect(allCases.contains(.peanuts))
        #expect(allCases.contains(.treeNuts))
        #expect(allCases.contains(.shellfish))
        #expect(allCases.contains(.fish))
        #expect(allCases.contains(.eggs))
        #expect(allCases.contains(.dairy))
        #expect(allCases.contains(.gluten))
        #expect(allCases.contains(.soy))
        #expect(allCases.contains(.sesame))
    }
    
    // MARK: - Additional DietType Tests
    
    @Test("All DietType cases are defined")
    func dietType_allCases_complete() async throws {
        let allCases = DietType.allCases
        
        #expect(allCases.count == 6)
        #expect(allCases.contains(.vegetarian))
        #expect(allCases.contains(.vegan))
        #expect(allCases.contains(.pescatarian))
        #expect(allCases.contains(.glutenFree))
        #expect(allCases.contains(.dairyFree))
        #expect(allCases.contains(.lowCarb))
    }
    
    @Test("DietType rawValues are correct")
    func dietType_rawValues_correct() async throws {
        #expect(DietType.vegetarian.rawValue == "Vegetarian")
        #expect(DietType.vegan.rawValue == "Vegan")
        #expect(DietType.pescatarian.rawValue == "Pescatarian")
        #expect(DietType.glutenFree.rawValue == "Gluten-Free")
        #expect(DietType.dairyFree.rawValue == "Dairy-Free")
        #expect(DietType.lowCarb.rawValue == "Low-Carb")
    }
    
    @Test("DietType all descriptions exist")
    func dietType_allDescriptions_exist() async throws {
        #expect(DietType.pescatarian.description == "No meat (fish OK)")
        #expect(DietType.dairyFree.description == "No milk products")
        #expect(DietType.lowCarb.description == "Reduced carbohydrates")
    }
    
    @Test("DietType all icons exist")
    func dietType_allIcons_exist() async throws {
        for dietType in DietType.allCases {
            #expect(!dietType.icon.isEmpty, "\(dietType) should have an icon")
        }
    }
    
    @Test("AllergyType all icons exist")
    func allergyType_allIcons_exist() async throws {
        for allergyType in AllergyType.allCases {
            #expect(!allergyType.icon.isEmpty, "\(allergyType) should have an icon")
        }
    }
    
    // MARK: - Firestore Round-Trip Tests
    
    @Test("toFirestore and fromFirestore round-trip preserves data")
    func firestore_roundTrip_preservesData() async throws {
        let original = DietaryPreferences(
            dietTypes: [.vegan, .glutenFree],
            allergies: [.peanuts, .dairy, .soy],
            dislikes: ["onions", "garlic", "peppers"],
            maxCookingTime: 45
        )
        
        let dict = original.toFirestore()
        let restored = DietaryPreferences.fromFirestore(dict)
        
        #expect(restored != nil)
        #expect(restored?.dietTypes == original.dietTypes)
        #expect(restored?.allergies == original.allergies)
        #expect(restored?.dislikes == original.dislikes)
        #expect(restored?.maxCookingTime == original.maxCookingTime)
    }
    
    @Test("toFirestore handles empty preferences")
    func toFirestore_emptyPreferences() async throws {
        let prefs = DietaryPreferences()
        let dict = prefs.toFirestore()
        
        #expect((dict["dietTypes"] as? [String])?.isEmpty == true)
        #expect((dict["allergies"] as? [String])?.isEmpty == true)
        #expect((dict["dislikes"] as? [String])?.isEmpty == true)
        #expect(dict["maxCookingTime"] as? Int == 60)
    }
    
    @Test("fromFirestore ignores unrecognized diet types")
    func fromFirestore_ignoresUnrecognizedDietTypes() async throws {
        let dict: [String: Any] = [
            "dietTypes": ["Vegetarian", "InvalidDiet", "Vegan"],
            "allergies": [],
            "dislikes": [],
            "maxCookingTime": 30
        ]
        
        let prefs = DietaryPreferences.fromFirestore(dict)
        
        // Should only include recognized diet types
        #expect(prefs?.dietTypes.count == 2)
        #expect(prefs?.dietTypes.contains(.vegetarian) == true)
        #expect(prefs?.dietTypes.contains(.vegan) == true)
    }
    
    // MARK: - Edge Case Tests
    
    @Test("toPromptString with all preferences set")
    func toPromptString_allPreferencesSet() async throws {
        let prefs = DietaryPreferences(
            dietTypes: [.vegan],
            allergies: [.gluten],
            dislikes: ["spicy food"],
            maxCookingTime: 20
        )
        
        let prompt = prefs.toPromptString()
        
        #expect(prompt.contains("USER DIETARY PREFERENCES"))
        #expect(prompt.contains("Diet Types"))
        #expect(prompt.contains("ALLERGIES"))
        #expect(prompt.contains("Dislikes"))
        #expect(prompt.contains("Maximum Cooking Time: 20 minutes"))
    }
}

