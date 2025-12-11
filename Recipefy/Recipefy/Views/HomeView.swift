//
//  HomeView.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/05/25.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var navigationState: NavigationState
  
  var body: some View {
    ZStack {
      // Background that extends to edges
      Color(.systemGroupedBackground)
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
            // Switch to Scan tab
            navigationState.navigateToTab(.scan)
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
              .background(Color(.systemBackground))
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
            
            // Saved Recipes Row
          NavigationLink(destination: FavoriteRecipesView()) {
            QuickActionRow(
              icon: "heart.fill",
              title: "Saved Recipes",
              subtitle: "Your Favorite Recipes"
            )
          }
          .buttonStyle(.plain)
          
          // My Ingredients Row
          Button {
            // Switch to Ingredients tab
            navigationState.navigateToTab(.ingredients)
          } label: {
            QuickActionRow(
              icon: "list.bullet.rectangle",
              title: "My Ingredients",
              subtitle: "View and Manage your Pantry"
            )
          }
          .buttonStyle(.plain)
          
          // Browse Recipes Row
          Button {
            // Switch to Recipes tab
            navigationState.navigateToTab(.recipes)
          } label: {
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
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(12)
    .padding(.horizontal)
    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

#Preview {
  HomeView()
}
