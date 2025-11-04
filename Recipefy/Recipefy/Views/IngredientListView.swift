//
//  IngredientListView.swift
//  Recipefy
//
//  Created by yuqi zou on 10/25/25.
//

import SwiftUI

struct IngredientListView: View {
  let scanId: String
  let imageData: Data
  @StateObject private var controller = IngredientController()
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Only show status when analyzing or there's an error
        if controller.isAnalyzing || (controller.currentIngredients == nil && !controller.statusText.isEmpty) {
          HStack(spacing: 8) {
            if controller.isAnalyzing {
              ProgressView().scaleEffect(0.8)
            }
            Text(controller.statusText).font(.footnote).foregroundStyle(.secondary)
          }
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue.opacity(0.1))
          .cornerRadius(12)
        }
        
        if let ingredients = controller.currentIngredients {
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              Text("Ingredients Found").font(.headline)
              Spacer()
              Text("\(ingredients.count)").font(.headline).foregroundStyle(.blue)
            }
            Divider()
            ForEach(ingredients.indices, id: \.self) { index in
              HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                  Text(ingredients[index].name.capitalized).font(.body)
                  HStack(spacing: 8) {
                    Text(ingredients[index].amount).font(.caption).foregroundStyle(.secondary)
                    Text("•").font(.caption).foregroundStyle(.secondary)
                    Text(ingredients[index].category).font(.caption).foregroundStyle(.blue)
                  }
                }
                Spacer()
              }
            }
          }
          .padding()
          .background(Color.blue.opacity(0.05))
          .cornerRadius(12)
        }
        
        Spacer()
      }
      .padding()
    }
    .navigationTitle("Ingredients")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      if controller.currentIngredients == nil && !controller.isAnalyzing {
        await controller.analyzeIngredients(imageData: imageData, scanId: scanId)
      }
    }
  }
}
