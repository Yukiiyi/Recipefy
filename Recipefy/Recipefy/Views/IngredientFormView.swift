//
//  IngredientFormView.swift
//  Recipefy
//
//  Created by streak honey on 11/5/25.
//

import SwiftUI

struct IngredientFormView: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var controller: IngredientController
  let scanId: String
  let ingredient: Ingredient? // Optional - nil for Add, populated for Edit
  
  @State private var name: String
  @State private var amount: String
  @State private var category: String
  @State private var isSaving = false
  @State private var showingDeleteAlert = false
  @State private var shouldDismiss = false
  
  let categories = ["Vegetables", "Proteins", "Grains", "Dairy", "Seasonings", "Oil", "Other"]
  
  // Computed property to determine if we're editing
  private var isEditing: Bool {
    ingredient != nil
  }
  
  // Initialize with optional ingredient for editing
  init(controller: IngredientController, scanId: String, ingredient: Ingredient? = nil) {
    self.controller = controller
    self.scanId = scanId
    self.ingredient = ingredient
    
    // Pre-fill with existing values if editing
    _name = State(initialValue: ingredient?.name ?? "")
    _amount = State(initialValue: ingredient?.amount ?? "")
    _category = State(initialValue: ingredient?.category ?? "Vegetables")
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section("Ingredient Name") {
          TextField("e.g., Chicken Breast", text: $name)
            .autocorrectionDisabled()
        }
        
        Section("Amount") {
          TextField("e.g., 2 cups, 500g", text: $amount)
            .autocorrectionDisabled()
        }
        
        Section("Category") {
          VStack(spacing: 10) {
            HStack(spacing: 10) {
              categoryButton("Vegetables")
              categoryButton("Proteins")
              categoryButton("Grains")
            }
            HStack(spacing: 8) {
              categoryButton("Dairy")
              categoryButton("Seasonings")
              categoryButton("Oil")
              categoryButton("Other")
            }
          }
          .padding(.vertical, 8)
        }
      }
      .navigationTitle(isEditing ? "Edit Ingredient" : "Add Ingredient")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            Task {
              isSaving = true
              if let ingredient = ingredient {
                // Editing existing ingredient
                await controller.updateIngredient(scanId: scanId, ingredient: ingredient, name: name, amount: amount, category: category)
              } else {
                // Adding new ingredient
                await controller.addIngredient(scanId: scanId, name: name, amount: amount, category: category)
              }
              isSaving = false
              shouldDismiss = true
            }
          }
          .disabled(name.isEmpty || amount.isEmpty || isSaving)
        }
        
        // Show delete button only when editing
        if isEditing {
          ToolbarItem(placement: .bottomBar) {
            Button(role: .destructive) {
              showingDeleteAlert = true
            } label: {
              HStack {
                Image(systemName: "trash")
                Text("Delete Ingredient")
              }
              .foregroundStyle(.red)
              .padding()
            }
          }
        }
      }
      .alert("Delete Ingredient", isPresented: $showingDeleteAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
          if let ingredient = ingredient {
            Task {
              await controller.deleteIngredient(scanId: scanId, ingredient: ingredient)
              dismiss()
            }
          }
        }
      } message: {
        Text("Are you sure you want to delete this ingredient?")
      }
      .onChange(of: shouldDismiss) { _, newValue in
        if newValue {
          dismiss()
        }
      }
    }
  }
  
  // helper function to create category buttons
  private func categoryButton(_ cat: String) -> some View {
    Button(action: {
      category = cat
    }) {
      Text(cat)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(category == cat ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(category == cat ? Color.green : Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
    .buttonStyle(.plain)
  }
}

#Preview("Add Ingredient") {
  IngredientFormView(
    controller: IngredientController(),
    scanId: "preview-scan-id"
  )
}

#Preview("Edit Ingredient") {
  IngredientFormView(
    controller: IngredientController(),
    scanId: "preview-scan-id",
    ingredient: Ingredient(
      id: "preview-ingredient-id",
      name: "Chicken Breast",
      amount: "500 g",
      category: "Proteins"
    )
  )
}

