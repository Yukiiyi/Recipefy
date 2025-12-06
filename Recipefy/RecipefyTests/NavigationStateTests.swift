//
//  NavigationStateTests.swift
//  RecipefyTests
//
//  Unit tests for NavigationState controller
//

import Testing
import Foundation
@testable import Recipefy

struct NavigationStateTests {
  
  // MARK: - Initialization Tests
  
  @Test("NavigationState initializes with tab 0 selected")
  func navigationState_initialState_defaultsToZero() {
    let sut = NavigationState()
    
    #expect(sut.selectedTab == 0)
  }
  
  // MARK: - Tab Enum Tests
  
  @Test("Tab enum has correct raw values")
  func tab_rawValues_correct() {
    #expect(NavigationState.Tab.home.rawValue == 0)
    #expect(NavigationState.Tab.ingredients.rawValue == 1)
    #expect(NavigationState.Tab.scan.rawValue == 2)
    #expect(NavigationState.Tab.recipes.rawValue == 3)
    #expect(NavigationState.Tab.settings.rawValue == 4)
  }
  
  @Test("Tab enum can be initialized from raw values")
  func tab_initFromRawValue_works() {
    #expect(NavigationState.Tab(rawValue: 0) == .home)
    #expect(NavigationState.Tab(rawValue: 1) == .ingredients)
    #expect(NavigationState.Tab(rawValue: 2) == .scan)
    #expect(NavigationState.Tab(rawValue: 3) == .recipes)
    #expect(NavigationState.Tab(rawValue: 4) == .settings)
  }
  
  @Test("Tab enum returns nil for invalid raw value")
  func tab_invalidRawValue_returnsNil() {
    #expect(NavigationState.Tab(rawValue: 5) == nil)
    #expect(NavigationState.Tab(rawValue: -1) == nil)
    #expect(NavigationState.Tab(rawValue: 100) == nil)
  }
  
  // MARK: - Navigation Tests
  
  @Test("navigateToTab changes selectedTab to home")
  func navigateToTab_home_changesSelectedTab() {
    let sut = NavigationState()
    sut.selectedTab = 3  // Start somewhere else
    
    sut.navigateToTab(.home)
    
    #expect(sut.selectedTab == 0)
  }
  
  @Test("navigateToTab changes selectedTab to ingredients")
  func navigateToTab_ingredients_changesSelectedTab() {
    let sut = NavigationState()
    
    sut.navigateToTab(.ingredients)
    
    #expect(sut.selectedTab == 1)
  }
  
  @Test("navigateToTab changes selectedTab to scan")
  func navigateToTab_scan_changesSelectedTab() {
    let sut = NavigationState()
    
    sut.navigateToTab(.scan)
    
    #expect(sut.selectedTab == 2)
  }
  
  @Test("navigateToTab changes selectedTab to recipes")
  func navigateToTab_recipes_changesSelectedTab() {
    let sut = NavigationState()
    
    sut.navigateToTab(.recipes)
    
    #expect(sut.selectedTab == 3)
  }
  
  @Test("navigateToTab changes selectedTab to settings")
  func navigateToTab_settings_changesSelectedTab() {
    let sut = NavigationState()
    
    sut.navigateToTab(.settings)
    
    #expect(sut.selectedTab == 4)
  }
  
  // MARK: - Direct Assignment Tests
  
  @Test("selectedTab can be directly assigned")
  func selectedTab_directAssignment_works() {
    let sut = NavigationState()
    
    sut.selectedTab = 2
    #expect(sut.selectedTab == 2)
    
    sut.selectedTab = 4
    #expect(sut.selectedTab == 4)
    
    sut.selectedTab = 0
    #expect(sut.selectedTab == 0)
  }
  
  // MARK: - Navigation Sequence Tests
  
  @Test("Can navigate through all tabs sequentially")
  func navigation_allTabs_sequential() {
    let sut = NavigationState()
    
    sut.navigateToTab(.home)
    #expect(sut.selectedTab == 0)
    
    sut.navigateToTab(.ingredients)
    #expect(sut.selectedTab == 1)
    
    sut.navigateToTab(.scan)
    #expect(sut.selectedTab == 2)
    
    sut.navigateToTab(.recipes)
    #expect(sut.selectedTab == 3)
    
    sut.navigateToTab(.settings)
    #expect(sut.selectedTab == 4)
  }
  
  @Test("Navigating to same tab doesn't change state")
  func navigation_sameTab_noChange() {
    let sut = NavigationState()
    sut.navigateToTab(.scan)
    
    let initialTab = sut.selectedTab
    sut.navigateToTab(.scan)
    
    #expect(sut.selectedTab == initialTab)
    #expect(sut.selectedTab == 2)
  }
}

