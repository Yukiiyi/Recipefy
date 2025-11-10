//
//  HomeView.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/05/25.
//

import SwiftUI

struct HomeView: View {
  @State private var navigateToScan = false
  
  var body: some View {
    ZStack {
      // Background that extends to edges
      Color(red: 0.98, green: 0.98, blue: 0.97)
        .ignoresSafeArea(.all)
      
      ScrollView {
        VStack(spacing: 24) {
          // Welcome Header - with safe area top padding
          Text("Welcome Back!")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top)
          
          // Green Call-to-Action Card
          VStack(alignment: .leading, spacing: 12) {
            Text("Fresh Ingredients?")
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.white)
            
            Text("Scan to get instant recipe ideas")
              .font(.system(size: 16, weight: .regular))
              .foregroundColor(.white.opacity(0.9))
            
          Button {
            navigateToScan = true
          } label: {
              HStack(spacing: 8) {
                Image(systemName: "camera.fill")
                  .font(.system(size: 16, weight: .semibold))
                Text("Start Scanning")
                  .font(.system(size: 16, weight: .semibold))
              }
              .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .background(Color.white)
              .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
          }
          .padding(20)
          .frame(maxWidth: .infinity)
          .background(Color(red: 0.36, green: 0.72, blue: 0.36))
          .cornerRadius(20)
          .padding(.horizontal)
          .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
          
          // Quick Actions Section
          VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(.primary)
              .padding(.horizontal)
            
          // My Ingredients Row
          NavigationLink(destination: PantryPlaceholderView()) {
            QuickActionRow(
              icon: "list.bullet.rectangle",
              title: "My Ingredients",
              subtitle: "View and Manage your Pantry"
            )
          }
          .buttonStyle(.plain)
            
          // Saved Recipes Row
          NavigationLink(destination: SavedRecipesPlaceholderView()) {
            QuickActionRow(
              icon: "heart.fill",
              title: "Saved Recipes",
              subtitle: "Your Favorite Recipes"
            )
          }
          .buttonStyle(.plain)
            
          // Browse Recipes Row
          NavigationLink(destination: BrowseRecipesPlaceholderView()) {
            QuickActionRow(
              icon: "fork.knife",
              title: "Browse Recipes",
              subtitle: "Explore new Recipe"
            )
          }
          .buttonStyle(.plain)
          }
          .padding(.top, 8)
          
          // Bottom padding to account for safe area
          Spacer()
            .frame(height: 20)
        }
      }
    }
    .navigationBarHidden(true)
    .navigationDestination(isPresented: $navigateToScan) {
      ScanRouteView()
    }
  }
}

struct QuickActionRow: View {
  let icon: String
  let title: String
  let subtitle: String
  
  var body: some View {
    HStack(spacing: 16) {
      // Icon with circular background
      ZStack {
        Circle()
          .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.15))
          .frame(width: 50, height: 50)
        
        Image(systemName: icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
      }
      
      // Text content
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 17, weight: .bold))
          .foregroundColor(.primary)
        
        Text(subtitle)
          .font(.system(size: 14, weight: .regular))
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      // Chevron
      Image(systemName: "chevron.right")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
    }
    .padding(.horizontal)
    .padding(.vertical, 14)
    .background(Color.white)
    .cornerRadius(12)
    .padding(.horizontal)
    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

#Preview {
  HomeView()
}

// MARK: - Inline placeholder screens (kept private to this file)

// Dedicated route that uses shared controller from environment
private struct ScanRouteView: View {
  @EnvironmentObject var controller: ScanController
  
  var body: some View {
    ScanView(controller: controller)
  }
}

private struct PantryPlaceholderView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("My Ingredients").font(.title).bold()
      Text("This is a placeholder pantry screen.")
        .foregroundStyle(.secondary)
      Spacer()
    }
    .padding()
    .navigationTitle("My Ingredients")
  }
}

private struct SavedRecipesPlaceholderView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("Saved Recipes").font(.title).bold()
      Text("This is a placeholder saved recipes screen.")
        .foregroundStyle(.secondary)
      Spacer()
    }
    .padding()
    .navigationTitle("Saved Recipes")
  }
}

private struct BrowseRecipesPlaceholderView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("Browse Recipes").font(.title).bold()
      Text("This is a placeholder browse screen.")
        .foregroundStyle(.secondary)
      Spacer()
    }
    .padding()
    .navigationTitle("Browse")
  }
}
