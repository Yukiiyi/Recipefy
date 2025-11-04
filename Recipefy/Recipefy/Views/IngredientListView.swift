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
        if let uiImage = UIImage(data: imageData) {
          Image(uiImage: uiImage).resizable().scaledToFit().frame(height: 160).cornerRadius(12)
        }
        
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
                Text("\(index + 1).").fontWeight(.semibold).foregroundStyle(.secondary)
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
        
        if controller.currentIngredients != nil && !controller.saveSuccess {
          Button {
            Task { await controller.saveIngredients(scanId: scanId) }
          } label: {
            HStack {
              if controller.isSaving {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
              } else {
                Image(systemName: "checkmark.circle.fill")
              }
              Text(controller.isSaving ? "Saving..." : "Save to Database")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(controller.isSaving ? Color.gray : Color.green)
            .cornerRadius(12)
          }
          .disabled(controller.isSaving)
        }
        
        if controller.saveSuccess {
          VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 50)).foregroundStyle(.green)
            Text("Saved Successfully!").font(.title3).fontWeight(.bold)
            Button("Done") { dismiss() }.buttonStyle(.borderedProminent)
          }
          .padding()
        }
        
        Spacer()
      }
      .padding()
    }
    .navigationTitle("Ingredients")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      if controller.currentIngredients == nil && !controller.isAnalyzing {
        await controller.analyzeIngredients(imageData: imageData)
      }
    }
  }
}
