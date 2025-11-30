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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Title
                Text("Profile")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                // MARK: - Profile Card
                profileCard
                
                // MARK: - Account Section
                sectionHeader("Account")
                VStack(spacing: 0) {
                    SettingsRow(icon: "person.fill", iconColor: .green,
                                title: "Edit Profile",
                                subtitle: "Name, Email , Password")
                    
                    divider
                    
                    SettingsRow(icon: "bell.fill", iconColor: .green,
                                title: "Notifications",
                                subtitle: "Recipe Suggestions, updates")
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)

                // MARK: - Dietary Preferences Section
                sectionHeader("Dietary Preferences")
                VStack(spacing: 0) {
                    SettingsRow(icon: "leaf.fill", iconColor: .green,
                                title: "Dietary Preferences",
                                subtitle: "Allergies, Restrictions")
                    
                }
                
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Content Section
                sectionHeader("Content")
                VStack(spacing: 0) {
                    SettingsRow(icon: "heart.fill", iconColor: .green,
                                title: "Saved Recipes",
                                subtitle: "3 recipes")
                    
                    divider
                    
                    SettingsRow(icon: "list.bullet", iconColor: .green,
                                title: "My Ingredients",
                                subtitle: "Manage pantry")
                    
                    divider
                    
                    SettingsRow(icon: "clock.fill", iconColor: .green,
                                title: "Recipe History",
                                subtitle: "Recipe viewed")
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Preferences Section
                sectionHeader("Preferences")
                VStack(spacing: 0) {
                    SettingsRow(icon: "questionmark.circle.fill", iconColor: .green,
                                title: "Help & Support")
                    
                    divider
                    
                    SettingsRow(icon: "shield.fill", iconColor: .green,
                                title: "Privacy Policy")
                    
                    divider
                    
                    SettingsRow(icon: "doc.text.fill", iconColor: .green,
                                title: "Terms of Service")
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Logout Button
                logoutButton
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.97))
        .navigationBarHidden(true)
    }
}

//
// MARK: - Profile Card
//
private extension SettingsView {

    var profileCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.green)
            }
            
            Text("Name")
                .font(.system(size: 20, weight: .semibold))
            
            Text("xxx@andrew.cmu.edu")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            HStack(spacing: 32) {
                profileStat(number: "12", label: "Recipes")
                profileStat(number: "45", label: "Cooked")
                profileStat(number: "3", label: "Favorites")
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }

    func profileStat(number: String, label: String) -> some View {
        VStack {
            Text(number)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.green)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

//
// MARK: - Section Header
//
private extension SettingsView {
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }
}

//
// MARK: - Row Divider
//
private extension SettingsView {
    var divider: some View {
        Divider()
            .padding(.leading, 56)
    }
}

//
// MARK: - Logout Button
//
private extension SettingsView {
    var logoutButton: some View {
        Button {
            authController.signOut()
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("Log Out")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.10))
            .cornerRadius(16)
        }
    }
}

//
// MARK: - Reusable Settings Row Component
//
struct SettingsRow: View {
    var icon: String
    var iconColor: Color = .green
    var title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
}

//
// MARK: - Preview
//
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthController())
    }
}
