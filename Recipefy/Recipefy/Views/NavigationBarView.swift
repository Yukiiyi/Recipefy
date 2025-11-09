//
//  NavigationBarView.swift
//  Recipefy
//
//  Created by Jonass Oh on 11/8/25.
//

import SwiftUI

public struct BottomNavBarView: View {
	@ObservedObject var vm: BottomNavBarViewModel
	@Namespace private var ns

	public init(viewModel: BottomNavBarViewModel) {
		self.vm = viewModel
	}

	public var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 22, style: .continuous)
					.fill(.ultraThinMaterial)
					.overlay(
							RoundedRectangle(cornerRadius: 22)
									.strokeBorder(.primary.opacity(0.08))
					)
					.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

			HStack(spacing: 0) {
				ForEach(vm.tabs) { tab in
					TabItem(
						tab: tab,
						isSelected: vm.selection == tab,
						namespace: ns
					) { vm.select(tab) }
				}
			}
			.padding(.horizontal, 8)
			.padding(.vertical, 8)
		}
		.frame(height: 80)
		.padding(.horizontal, 12)
		.padding(.bottom, 10)
		.ignoresSafeArea(.keyboard, edges: .bottom)
	}
}

private struct TabItem: View {
	let tab: AppTab
	let isSelected: Bool
	let namespace: Namespace.ID
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			VStack(spacing: 4) {
				ZStack {
					if isSelected {
						Circle()
							.fill(Color.accentColor)
							.matchedGeometryEffect(id: "selected-pill", in: namespace)
							.frame(width: 44, height: 44)
							.shadow(radius: 8, y: 4)
					}
					Image(systemName: tab.systemImage)
						.font(.system(size: 20, weight: .semibold))
						.foregroundStyle(isSelected ? .white : .secondary)
						.scaleEffect(isSelected ? 1.1 : 1.0)
				}
				Text(tab.title)
					.font(.caption2)
					.foregroundStyle(isSelected ? Color.accentColor : .secondary)
			}
			.frame(maxWidth: .infinity)
			.padding(.vertical, 6)
		}
		.buttonStyle(.plain)
	}
}

// MARK: Example Demo of Navigation Bar

struct ExampleHostView: View {
	@StateObject private var navVM = BottomNavBarViewModel(initial: .home)

	var body: some View {
		ZStack {
			Group {
				switch navVM.selection {
				case .home:        NavigationStack { Text("Home").navigationTitle("Home") }
				case .ingredients: NavigationStack { Text("Ingredients").navigationTitle("Ingredients") }
				case .scan:        NavigationStack { Text("Scan").navigationTitle("Scan") }
				case .recipes:     NavigationStack { Text("Recipes").navigationTitle("Recipes") }
				case .settings:    NavigationStack { Text("Settings").navigationTitle("Settings") }
				}
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color(.systemBackground))

			VStack {
				Spacer()
				BottomNavBarView(viewModel: navVM)
			}
		}
	}
}

#Preview {
	ExampleHostView()
}
