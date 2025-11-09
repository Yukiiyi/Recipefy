//
//  SimulatorCameraSupport.swift
//  Recipefy
//
//  Created by AI Assistant on 11/7/25.
//
//  SIMULATOR SUPPORT: This file contains all simulator-specific code for camera functionality.
//  To remove simulator support in production, simply delete this file and remove references marked with "SIMULATOR SUPPORT"

import UIKit
import SwiftUI

/// Helper class that encapsulates all simulator-specific camera functionality
struct SimulatorCameraSupport {
  
  // Detection
  
  /// Checks if the app is running on a simulator
  static var isRunningOnSimulator: Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return false
    #endif
  }
  
  // Mock Image Generation
  
  /// Generates a mock ingredient image for testing on simulator
  static func generateMockIngredientImage() -> UIImage {
    let size = CGSize(width: 400, height: 600)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let image = renderer.image { context in
      // Background
      UIColor.systemGray5.setFill()
      context.fill(CGRect(origin: .zero, size: size))
      
      // Mock ingredient items
      let ingredients = ["🥕 Carrots", "🥬 Lettuce", "🍅 Tomatoes", "🥒 Cucumber", "🧅 Onion"]
      
      for (index, ingredient) in ingredients.enumerated() {
        let y = 100 + (index * 80)
        
        // Item background
        UIColor.white.setFill()
        let rect = CGRect(x: 20, y: CGFloat(y), width: 360, height: 60)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        path.fill()
        
        // Text
        let text = ingredient
        let attributes: [NSAttributedString.Key: Any] = [
          .font: UIFont.systemFont(ofSize: 24),
          .foregroundColor: UIColor.black
        ]
        let textRect = CGRect(x: 40, y: CGFloat(y + 15), width: 320, height: 40)
        text.draw(in: textRect, withAttributes: attributes)
      }
      
      // Watermark
      let watermark = "SIMULATOR TEST IMAGE"
      let watermarkAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14, weight: .bold),
        .foregroundColor: UIColor.systemRed
      ]
      watermark.draw(at: CGPoint(x: 120, y: 550), withAttributes: watermarkAttributes)
    }
    
    return image
  }
  
  // UI Components
  
  /// SwiftUI view that provides a mock camera background for simulator
  struct MockCameraView: View {
    let capturedPhotosCount: Int
    
    var body: some View {
      ZStack {
        // Mock fridge/pantry background
        LinearGradient(
          colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
        
        // Grid overlay (same as real camera)
        GridOverlayView()
          .ignoresSafeArea()
        
        // Simulator notice
        VStack {
          Spacer()
          HStack(spacing: 8) {
            Image(systemName: "info.circle.fill")
              .font(.caption)
            Text("Simulator Mode: Tap capture to generate test images")
              .font(.caption)
              .fontWeight(.medium)
          }
          .foregroundStyle(.white)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(
            Capsule()
              .fill(Color.blue.opacity(0.8))
          )
          .padding(.bottom, capturedPhotosCount == 0 ? 180 : 240)
        }
      }
    }
  }
}

