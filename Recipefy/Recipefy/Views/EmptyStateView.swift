//
//  EmptyStateView.swift
//  Recipefy
//
//  Created by streak honey on 11/9/25.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonText: String?
    let buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
            }
            
            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Optional button
            if let buttonText = buttonText, let buttonAction = buttonAction {
                Button(action: buttonAction) {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.36, green: 0.72, blue: 0.36))
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
    }
}

#Preview {
    EmptyStateView(
        icon: "camera.fill",
        title: "No Ingredients Yet",
        message: "Scan ingredients to get started",
        buttonText: "Go to Scan",
        buttonAction: { print("Button tapped") }
    )
}

