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
  @StateObject private var cameraManager = CameraManager()
  @ObservedObject var controller: ScanController
  
  // Photo collection
  @State private var capturedImages: [UIImage] = []
  @State private var capturedImageData: [Data] = []
  
  // Photo picker
  @State private var pickerItem: PhotosPickerItem?
  @State private var showingPhotoPicker = false
  
  // UI states
  @State private var showingInstructions = false
  @State private var navigateToReviewScans = false
  
  private let maxPhotos = 5
  
  var body: some View {
    ZStack {
      // Camera preview background
      // SIMULATOR SUPPORT: Remove this if-block to disable simulator mock view
      if cameraManager.isSimulator {
        SimulatorCameraSupport.MockCameraView(capturedPhotosCount: capturedImages.count)
      } else if cameraManager.isAuthorized && !cameraManager.isCameraUnavailable {
        CameraPreviewView(session: cameraManager.session)
          .ignoresSafeArea()
        
        // Grid overlay
        GridOverlayView()
          .ignoresSafeArea()
      } else if cameraManager.isCameraUnavailable {
        cameraUnavailableView
      } else if !cameraManager.isAuthorized {
        cameraPermissionView
      }
      
      // Main UI overlay
      VStack(spacing: 0) {
        // Top navigation bar
        topNavigationBar
          .padding()
        
        Spacer(minLength: 0)
        
        // Status indicator (photos captured)
        if !capturedImages.isEmpty {
          photoCountBadge
            .padding(.bottom, 16)
        }
        
        // Bottom control bar
        bottomControlBar
          .padding(.horizontal)
          .padding(.bottom, 12)
      }
    }
    .navigationBarHidden(true)
    .task {
      await cameraManager.checkAuthorization()
    }
    .onDisappear {
      cameraManager.stopSession()
    }
    .onChange(of: cameraManager.capturedImage) { _, newImage in
      if let image = newImage, capturedImages.count < maxPhotos {
        Task {
          await addCapturedImage(image)
        }
        cameraManager.capturedImage = nil
      }
      }
      .onChange(of: pickerItem) { _, newItem in
        Task {
          guard let item = newItem,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data),
              capturedImages.count < maxPhotos else { return }
          await addCapturedImage(image)
          pickerItem = nil
      }
    }
    .sheet(isPresented: $showingInstructions) {
      instructionsSheet
    }
    .navigationDestination(isPresented: $navigateToReviewScans) {
      ReviewScansView(
        capturedImages: $capturedImages,
        capturedImageData: $capturedImageData,
        controller: controller
      )
    }
  }
  
  // Top Navigation Bar
  private var topNavigationBar: some View {
    HStack {
      Button(action: {
        // Handle back navigation
      }) {
        Image(systemName: "chevron.left")
          .font(.title3)
          .foregroundStyle(.white)
          .padding(10)
          .background(Circle().fill(Color.black.opacity(0.5)))
      }
      .buttonStyle(.plain)
      
      Spacer()
      
      Button(action: {
        // Handle close
      }) {
        Image(systemName: "xmark")
          .font(.title3)
          .foregroundStyle(.white)
          .padding(10)
          .background(Circle().fill(Color.black.opacity(0.5)))
      }
      .buttonStyle(.plain)
    }
  }
  
  // Photo Count Badge
  private var photoCountBadge: some View {
    HStack(spacing: 8) {
      Image(systemName: "photo.stack")
        .font(.subheadline)
      Text("\(capturedImages.count) photo\(capturedImages.count == 1 ? "" : "s") captured")
        .font(.subheadline)
        .fontWeight(.medium)
    }
    .foregroundStyle(.white)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(
      Capsule()
        .fill(Color.black.opacity(0.7))
    )
  }
  
  // Bottom Control Bar
  private var bottomControlBar: some View {
    VStack(spacing: 16) {
      // Camera controls
      HStack(alignment: .center) {
        // Gallery button
        Button(action: {
          showingPhotoPicker = true
        }) {
          VStack(spacing: 4) {
            Image(systemName: "photo.on.rectangle")
              .font(.title2)
            Text("Gallery")
              .font(.caption)
          }
          .foregroundStyle(.white)
          .frame(width: 80)
        }
        .buttonStyle(.plain)
        .disabled(capturedImages.count >= maxPhotos)
        .opacity(capturedImages.count >= maxPhotos ? 0.5 : 1)
        .photosPicker(
          isPresented: $showingPhotoPicker,
          selection: $pickerItem,
          matching: .images
        )
        
        Spacer()
        
        // Capture button
        Button(action: {
          cameraManager.capturePhoto()
        }) {
          ZStack {
            Circle()
              .stroke(Color.white, lineWidth: 4)
              .frame(width: 70, height: 70)
            
            Circle()
              .fill(Color.white)
              .frame(width: 60, height: 60)
          }
        }
        .buttonStyle(.plain)
        .disabled(capturedImages.count >= maxPhotos || !cameraManager.isAuthorized)
        .opacity(capturedImages.count >= maxPhotos ? 0.5 : 1)
        
        Spacer()
        
        // Instructions button
        Button(action: {
          showingInstructions = true
        }) {
          VStack(spacing: 4) {
            Image(systemName: "info.circle")
              .font(.title2)
            Text("Instructions")
              .font(.caption)
          }
          .foregroundStyle(.white)
          .frame(width: 80)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .fill(Color.black.opacity(0.7))
      )
    }
  }
  
  // Camera Unavailable View
  private var cameraUnavailableView: some View {
    VStack(spacing: 20) {
      Image(systemName: "camera.metering.unknown")
        .font(.system(size: 60))
        .foregroundStyle(.secondary)
      
      Text("Camera Unavailable")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Your device's camera is not available.")
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding()
  }
  
  // Camera Permission View
  private var cameraPermissionView: some View {
    VStack(spacing: 20) {
      Image(systemName: "camera.fill")
        .font(.system(size: 60))
        .foregroundStyle(.secondary)
      
      Text("Camera Access Required")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Please allow camera access in Settings to scan your ingredients.")
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      
      Button("Open Settings") {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(settingsUrl)
        }
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
  }
  
  // Instructions Sheet
  private var instructionsSheet: some View {
    NavigationView {
      VStack(alignment: .leading, spacing: 24) {
        instructionItem(
          icon: "camera.fill",
          title: "Take Clear Photos",
          description: "Take photos of ingredients you want to use. Make sure desired ingredients are clearly displayed and well-lit."
        )
        
        instructionItem(
          icon: "photo.stack",
          title: "Multiple Images",
          description: "You can take multiple images (e.g., fridge, pantry) to capture all your ingredients. Maximum 5 photos per scan."
        )
        
        instructionItem(
          icon: "arrow.triangle.2.circlepath",
          title: "Auto-Deduplication",
          description: "Duplicate ingredients are handled automatically, so don't worry if the same item appears in multiple photos."
        )
      }
      .padding(24)
      .navigationTitle("How to Scan")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            showingInstructions = false
          }
        }
      }
    }
    .presentationDetents([.medium])
  }
  
  private func instructionItem(icon: String, title: String, description: String) -> some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.green)
        .frame(width: 32)
      
      VStack(alignment: .leading, spacing: 6) {
        Text(title)
          .font(.headline)
        
        Text(description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
  }
  
  // Helper Functions
  private func addCapturedImage(_ image: UIImage) async {
    guard capturedImages.count < maxPhotos else { return }
    
    // Convert to data on background thread (this is the slow part)
    let imageData = await Task.detached {
      image.jpegData(compressionQuality: 0.75)
    }.value
    
    // Update UI on main thread
    await MainActor.run {
      capturedImages.append(image)
      if let data = imageData {
        capturedImageData.append(data)
      }
      // Navigate to review scans screen
      navigateToReviewScans = true
    }
  }
}
