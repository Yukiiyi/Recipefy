//
//  ReviewScansView.swift
//  Recipefy
//
//  Created by AI Assistant on 11/7/25.
//

import SwiftUI

struct ReviewScansView: View {
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var navigationState: NavigationState
  @Binding var capturedImages: [UIImage]
  @Binding var capturedImageData: [Data]
  @ObservedObject var controller: ScanController
  
  @State private var isProcessing = false
  
  private let maxPhotos = 5
  
  let columns = [
    GridItem(.flexible(), spacing: 16),
    GridItem(.flexible(), spacing: 16)
  ]
  
  var body: some View {
    VStack(spacing: 0) {
      // Info banner
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "info.circle.fill")
          .font(.title3)
          .foregroundStyle(.green)
        
        Text("Review your Ingredient images. Our AI will identify all clear ingredients and handle duplicate ingredients automatically")
          .font(.subheadline)
          .foregroundStyle(.primary)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding()
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.green.opacity(0.15))
      .cornerRadius(12)
      .padding()
      
      // Photo grid
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(Array(capturedImages.enumerated()), id: \.offset) { index, image in
            photoCard(image: image, index: index)
          }
        }
        .padding(.horizontal)
      }
      
      Spacer()
      
      // Action buttons
      VStack(spacing: 12) {
        // Scan More button
        Button(action: {
          dismiss()
        }) {
          HStack(spacing: 8) {
            Image(systemName: "camera")
              .font(.headline)
            Text("Scan More")
              .font(.headline)
          }
          .foregroundStyle(.green)
          .frame(maxWidth: .infinity)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.green, lineWidth: 2)
          )
        }
        .buttonStyle(.plain)
        .disabled(capturedImages.count >= maxPhotos)
        .opacity(capturedImages.count >= maxPhotos ? 0.5 : 1)
        
        // Process Images button
        Button(action: processImages) {
          HStack(spacing: 8) {
            Image(systemName: "arrow.right")
              .font(.headline)
            Text("Process Images")
              .font(.headline)
          }
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.green)
          .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(capturedImages.isEmpty || isProcessing)
      }
      .padding()
    }
    .navigationTitle("Review Scans")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(false)
    .overlay {
      if isProcessing {
        processingOverlay
      }
    }
  }
  
  // Photo Card
  private func photoCard(image: UIImage, index: Int) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Photo #\(index + 1)")
          .font(.subheadline)
          .fontWeight(.semibold)
        
        Spacer()
        
        Button(action: {
          removePhoto(at: index)
        }) {
          Image(systemName: "xmark.circle.fill")
            .font(.title2)
            .foregroundStyle(.red)
        }
        .buttonStyle(.plain)
      }
      
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(height: 200)
        .clipped()
        .cornerRadius(12)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.blue, lineWidth: 3)
        )
    }
  }
  
  // Processing Overlay
  private var processingOverlay: some View {
    ZStack {
      Color.black.opacity(0.7)
        .ignoresSafeArea()
      
      VStack(spacing: 16) {
        ProgressView()
          .scaleEffect(1.5)
          .tint(.white)
        
        Text(controller.statusText)
          .font(.headline)
          .foregroundStyle(.white)
      }
      .padding(32)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color.black.opacity(0.8))
      )
    }
  }
  
  // Helper Functions
  private func removePhoto(at index: Int) {
    capturedImages.remove(at: index)
    capturedImageData.remove(at: index)
  }
  
  private func processImages() {
    guard !capturedImageData.isEmpty else { return }
    
    isProcessing = true
    
    Task {
      await controller.uploadAndCreateScanWithMultipleImages(imageDataArray: capturedImageData)
      
      isProcessing = false
      
      if controller.currentScanId != nil {
        // Switch to Ingredients tab (no need to navigate within Scan tab)
        navigationState.navigateToTab(.ingredients)
      }
    }
  }
}

