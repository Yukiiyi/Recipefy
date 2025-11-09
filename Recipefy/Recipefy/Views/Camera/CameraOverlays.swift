//
//  CameraOverlays.swift
//  Recipefy
//
//  Created by AI Assistant on 11/7/25.
//

import SwiftUI

// Focus box overlay for camera view (corner brackets to guide composition)
struct GridOverlayView: View {
  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let height = geometry.size.height
      
      // FOCUS BOX CONFIGURATION - Adjust these values to move/resize the focus box
      let cornerLength: CGFloat = 30           // Length of each corner line (smaller = tighter frame)
      let cornerThickness: CGFloat = 3         // Thickness of corner lines
      let boxWidth: CGFloat = width * 0.65     // Width of focus box (0.65 = 65% of screen width)
      let boxHeight: CGFloat = height * 0.35   // Height of focus box (0.35 = 35% of screen height)
      let verticalOffset: CGFloat = -40        // Move up (negative) or down (positive) from center
      let horizontalOffset: CGFloat = 0        // Move left (negative) or right (positive) from center
      
      // Calculate center position
      let centerX = width / 2 + horizontalOffset
      let centerY = height / 2 + verticalOffset
      let halfWidth = boxWidth / 2
      let halfHeight = boxHeight / 2
      
      // Corner positions
      let topLeft = CGPoint(x: centerX - halfWidth, y: centerY - halfHeight)
      let topRight = CGPoint(x: centerX + halfWidth, y: centerY - halfHeight)
      let bottomLeft = CGPoint(x: centerX - halfWidth, y: centerY + halfHeight)
      let bottomRight = CGPoint(x: centerX + halfWidth, y: centerY + halfHeight)
      
      ZStack {
        // Top-left corner
        Path { path in
          // Horizontal line
          path.move(to: topLeft)
          path.addLine(to: CGPoint(x: topLeft.x + cornerLength, y: topLeft.y))
          // Vertical line
          path.move(to: topLeft)
          path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerLength))
        }
        .stroke(Color.white, lineWidth: cornerThickness)
        
        // Top-right corner
        Path { path in
          // Horizontal line
          path.move(to: topRight)
          path.addLine(to: CGPoint(x: topRight.x - cornerLength, y: topRight.y))
          // Vertical line
          path.move(to: topRight)
          path.addLine(to: CGPoint(x: topRight.x, y: topRight.y + cornerLength))
        }
        .stroke(Color.white, lineWidth: cornerThickness)
        
        // Bottom-left corner
        Path { path in
          // Horizontal line
          path.move(to: bottomLeft)
          path.addLine(to: CGPoint(x: bottomLeft.x + cornerLength, y: bottomLeft.y))
          // Vertical line
          path.move(to: bottomLeft)
          path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - cornerLength))
        }
        .stroke(Color.white, lineWidth: cornerThickness)
        
        // Bottom-right corner
        Path { path in
          // Horizontal line
          path.move(to: bottomRight)
          path.addLine(to: CGPoint(x: bottomRight.x - cornerLength, y: bottomRight.y))
          // Vertical line
          path.move(to: bottomRight)
          path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerLength))
        }
        .stroke(Color.white, lineWidth: cornerThickness)
      }
    }
  }
}

