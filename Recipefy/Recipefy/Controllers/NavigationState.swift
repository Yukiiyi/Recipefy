//
//  NavigationState.swift
//  Recipefy
//
//  Created by AI Assistant on 11/13/25.
//

import Foundation
import Combine

/// Manages the selected tab in the main navigation bar
class NavigationState: ObservableObject {
    @Published var selectedTab: Int = 0
    
    enum Tab: Int {
        case home = 0
        case ingredients = 1
        case scan = 2
        case recipes = 3
        case settings = 4
    }
    
    func navigateToTab(_ tab: Tab) {
        selectedTab = tab.rawValue
    }
}

