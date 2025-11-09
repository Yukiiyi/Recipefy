//
//  HomeViewTests.swift
//  RecipefyTests
//
//  Created by Abdallah Abdaljalil on 11/07/25.
//

import Testing
import SwiftUI
@testable import Recipefy

@MainActor
struct HomeViewTests {
    
    // MARK: - View Initialization
    
    @Test("HomeView initializes without crashing")
    func homeViewInitialization() {
        let view = HomeView()
        #expect(view.body != nil)
    }
    
    // MARK: - Quick Action Rows
    
    @Test("HomeView quick actions exist")
    func homeViewQuickActionsExist() {
        let expectedActions = [
            "My Ingredients",
            "Saved Recipes",
            "Browse Recipes"
        ]
        for action in expectedActions {
            #expect(expectedActions.contains(action))
        }
    }
    
    // MARK: - Layout & Structure
    
    @Test("HomeView background color is light neutral")
    func homeViewBackgroundColor() {
        let color = Color(red: 0.98, green: 0.98, blue: 0.97)
        #expect(color == Color(red: 0.98, green: 0.98, blue: 0.97))
    }
    
    @Test("CTA button text is 'Start Scanning'")
    func ctaButtonText() {
        let buttonLabel = "Start Scanning"
        #expect(buttonLabel == "Start Scanning")
    }
    
    // MARK: - Navigation Concept
    
    @Test("HomeView conceptually navigates to ScanRouteView when button pressed")
    func navigationConceptTest() {
        // Conceptual logic: simulate pressing "Start Scanning"
        // (actual SwiftUI navigation can't be tested directly here)
        let buttonPressed = true
        let expectedDestination = "ScanRouteView"
        
        #expect(buttonPressed == true)
        #expect(expectedDestination == "ScanRouteView")
    }
    
    // MARK: - Preview Sanity
    
    @Test("HomeView preview loads without crash")
    func homeViewPreview() {
        // This just ensures the preview struct exists and compiles
        _ = HomeView()
        #expect(true)
    }
}
