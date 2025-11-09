//
//  NavigationBarViewModel.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI
import Combine

public enum AppTab: CaseIterable, Hashable, Identifiable {
	case home, ingredients, scan, recipes, settings
	public var id: Self { self }

	var title: String {
		switch self {
		case .home: return "Home"
		case .ingredients: return "Ingredients"
		case .scan: return "Scan"
		case .recipes: return "Recipes"
		case .settings: return "Settings"
		}
	}

	var systemImage: String {
		switch self {
		case .home: return "house.fill"
		case .ingredients: return "list.bullet"
		case .scan: return "camera.fill"
		case .recipes: return "fork.knife"
		case .settings: return "gearshape.fill"
		}
	}
}

public final class BottomNavBarViewModel: ObservableObject {
	@Published public var selection: AppTab
	public let tabs: [AppTab] = AppTab.allCases

	public init(initial selection: AppTab = .home) {
		self.selection = selection
	}

	@MainActor
	public func select(_ tab: AppTab) {
		withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
			selection = tab
		}
		#if canImport(UIKit)
		UIImpactFeedbackGenerator(style: .light).impactOccurred()
		#endif
	}
}
