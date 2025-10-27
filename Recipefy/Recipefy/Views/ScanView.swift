//
//  ScanView.swift
//  Recipefy
//
//  Created by streak honey on 10/24/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct ScanView: View {
  @State private var pickerItem: PhotosPickerItem?
  @ObservedObject var controller: ScanController
  @State private var pickedImage: UIImage?
  @State private var imageData: Data?
  @State private var navigateToIngredients = false
  
  var body: some View {
    VStack(spacing: 16) {
      Text(controller.statusText)
        .font(.footnote)
        .foregroundStyle(.secondary)
        
      PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
        Text("Pick Photo")
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue.opacity(0.15))
          .cornerRadius(12)
      }
      .onChange(of: pickerItem) { _, newItem in
        Task {
          guard let item = newItem,
                let raw = try? await item.loadTransferable(type: Data.self) else { return }
          pickedImage = UIImage(data: raw)
          imageData = raw
        }
      }
      
      if let img = pickedImage {
        Image(uiImage: img).resizable().scaledToFit().frame(height: 160).cornerRadius(12)
      }
        
      Button("Upload & Create Scan") {
        Task {
          guard let data = imageData else { return }
          let compressedData: Data
          if let uiImg = UIImage(data: data), let jpeg = uiImg.jpegData(compressionQuality: 0.75) {
            compressedData = jpeg
          } else {
            compressedData = data
          }
          await controller.uploadAndCreateScan(imageData: compressedData)
          if controller.lastScanId != nil {
            navigateToIngredients = true
          }
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(pickerItem == nil)

      if let id = controller.lastScanId {
        Text("Scan ID: \(id)")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Spacer()
      
      NavigationLink(destination: Group {
        if let scanId = controller.lastScanId, let data = imageData {
          IngredientScreen(scanId: scanId, imageData: data)
        } else {
          EmptyView()
        }
      }, isActive: $navigateToIngredients, label: { EmptyView() })
    }
    .padding()
    .navigationTitle("New Scan")
  }
}
