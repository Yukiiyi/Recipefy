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
  @State private var quantity: String
  @State private var unit: MeasurementUnit?
  @State private var category: IngredientCategory
  @State private var isSaving = false
  @State private var showingDeleteAlert = false
  @State private var shouldDismiss = false
  @State private var quantityError: String?
  
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
    _quantity = State(initialValue: ingredient?.quantity ?? "")
    
    // Parse unit string to MeasurementUnit enum
    // For new ingredients, start with nil (forces user to select)
    // For editing, use existing value
    if let unitString = ingredient?.unit {
      _unit = State(initialValue: MeasurementUnit(rawValue: unitString))
    } else {
      _unit = State(initialValue: nil)
    }
    
    _category = State(initialValue: ingredient?.category ?? .vegetables)
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section("Ingredient Name") {
          TextField("e.g., Chicken Breast", text: $name)
            .autocorrectionDisabled()
        }
        
        Section {
          // Quantity
          VStack(alignment: .leading, spacing: 4) {
            HStack {
              Text("Quantity")
                .frame(width: 80, alignment: .leading)
              TextField("e.g., 2", text: $quantity)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: quantity) { oldValue, newValue in
                  // Clear error when user starts typing
                  quantityError = nil
                }
            }
            
            // Error message
            if let error = quantityError {
              Text(error)
                .font(.caption)
                .foregroundStyle(.red)
                .padding(.leading, 80)
            }
          }
          
          // Unit
          Picker("Unit", selection: $unit) {
            Text("Select unit...").tag(MeasurementUnit?.none)
            
            Section(header: Text("Volume")) {
              ForEach(MeasurementUnit.volumeUnits) { unit in
                Text(unit.displayName).tag(MeasurementUnit?.some(unit))
              }
            }
            
            Section(header: Text("Weight")) {
              ForEach(MeasurementUnit.weightUnits) { unit in
                Text(unit.displayName).tag(MeasurementUnit?.some(unit))
              }
            }
            
            Section(header: Text("Count")) {
              ForEach(MeasurementUnit.countUnits) { unit in
                Text(unit.displayName).tag(MeasurementUnit?.some(unit))
              }
            }
          }
        } header: {
          Text("Amount")
        } footer: {
          Text("Enter quantity (e.g., 2, 0.5, 1/4) and select a unit")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        
        Section("Category") {
          VStack(spacing: 10) {
            HStack(spacing: 10) {
              categoryButton(.vegetables)
              categoryButton(.proteins)
              categoryButton(.grains)
            }
            HStack(spacing: 8) {
              categoryButton(.dairy)
              categoryButton(.seasonings)
              categoryButton(.oil)
              categoryButton(.other)
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
            // Validate quantity first
            if !isValidQuantity(quantity) {
              quantityError = "Please enter a valid number"
              return
            }
            
            // Ensure unit is selected
            guard let selectedUnit = unit else {
              return
            }
            
            Task {
              isSaving = true
              if let ingredient = ingredient {
                // Editing existing ingredient
                await controller.updateIngredient(scanId: scanId, ingredient: ingredient, name: name, quantity: quantity, unit: selectedUnit.rawValue, category: category)
              } else {
                // Adding new ingredient
                await controller.addIngredient(scanId: scanId, name: name, quantity: quantity, unit: selectedUnit.rawValue, category: category)
              }
              isSaving = false
              shouldDismiss = true
            }
          }
          .disabled(name.isEmpty || quantity.isEmpty || unit == nil || isSaving)
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
      .alert("Error", isPresented: .constant(controller.errorMessage != nil)) {
        Button("OK") {
          controller.errorMessage = nil
        }
      } message: {
        if let errorMessage = controller.errorMessage {
          Text(errorMessage)
        }
      }
    }
  }
  
  // helper function to create category buttons
  private func categoryButton(_ cat: IngredientCategory) -> some View {
    Button(action: {
      category = cat
    }) {
      Text(cat.rawValue)
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
  
  // Validation helper
  private func isValidQuantity(_ input: String) -> Bool {
    let trimmed = input.trimmingCharacters(in: .whitespaces)
    
    // Allow empty (will be caught by .disabled on button)
    if trimmed.isEmpty {
      return true
    }
    
    // Check if it's a valid decimal number
    if Double(trimmed) != nil {
      return true
    }
    
    // Check if it's a valid fraction (e.g., "1/2")
    let fractionPattern = "^\\d+/\\d+$"
    if let regex = try? NSRegularExpression(pattern: fractionPattern),
       regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
      return true
    }
    
    return false
  }
}

#Preview("Add Ingredient") {
  IngredientFormView(
    controller: IngredientController(
      geminiService: GeminiService(),
      firestoreService: FirebaseFirestoreService()
    ),
    scanId: "preview-scan-id"
  )
}

#Preview("Edit Ingredient") {
  IngredientFormView(
    controller: IngredientController(
      geminiService: GeminiService(),
      firestoreService: FirebaseFirestoreService()
    ),
    scanId: "preview-scan-id",
    ingredient: Ingredient(
      id: "preview-ingredient-id",
      name: "Chicken Breast",
      quantity: "500",
      unit: "gram",
      category: .proteins
    )
  )
}

