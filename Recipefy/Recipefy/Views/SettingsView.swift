//
//  SettingsView.swift
//  Recipefy
//
//  Created by streak honey on 11/9/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Placeholder icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
            }
            
            Text("Settings")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Coming Soon")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Log Out button at bottom
            Button {
                authController.signOut()
            } label: {
                Text("Log Out")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthController())
    }
}

