//
//  SettingsView.swift
//  Recipefy
//
//  Created by streak honey on 11/9/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    @EnvironmentObject var authController: AuthController
    
    // Dynamic stats
    @State private var recipesCount: Int = 0
    @State private var ingredientsCount: Int = 0
    @State private var favoritesCount: Int = 0
    @State private var isLoadingStats: Bool = true

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
                    
                    NavigationLink(destination: EditProfileView()) {
                        SettingsRow(icon: "person.fill", iconColor: .green,
                                    title: "Edit Profile",
                                    subtitle: "Name, Email , Password")
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Dietary Preferences Section
                sectionHeader("Dietary Preferences")
                VStack(spacing: 0) {
                    NavigationLink(destination: PreferencesView()) {
                        SettingsRow(icon: "leaf.fill", iconColor: .green,
                                    title: "Dietary Preferences",
                                    subtitle: "Allergies, Restrictions")
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Content Section
                sectionHeader("Content")
                VStack(spacing: 0) {
                    NavigationLink(destination: FavoriteRecipesView()) {
                        SettingsRow(icon: "heart.fill", iconColor: .green,
                                    title: "Saved Recipes",
                                    subtitle: "Your favorites")
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Preferences Section
                sectionHeader("Preferences")
                VStack(spacing: 0) {
                    
                    NavigationLink(destination: HelpAndSupportView()) {
                        SettingsRow(icon: "questionmark.circle.fill", iconColor: .green,
                                    title: "Help & Support")
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        SettingsRow(icon: "shield.fill", iconColor: .green,
                                    title: "Privacy Policy")
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        SettingsRow(icon: "doc.text.fill", iconColor: .green,
                                    title: "Terms of Service")
                    }
                    .buttonStyle(.plain)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Logout Button
                logoutButton
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .task {
            await loadStats()
        }
    }
    
    // MARK: - Load Stats from Firestore
    private func loadStats() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoadingStats = false
            return
        }
        
        let db = Firestore.firestore()
        
        do {
            // Load recipes count
            let recipesSnapshot = try await db.collection("users").document(uid).collection("recipes").getDocuments()
            recipesCount = recipesSnapshot.documents.count
            
            // Load ingredients count
            let ingredientsSnapshot = try await db.collection("users").document(uid).collection("ingredients").getDocuments()
            ingredientsCount = ingredientsSnapshot.documents.count
            
            // Load favorites count (saved recipes)
            let favoritesSnapshot = try await db.collection("users").document(uid).collection("favorites").getDocuments()
            favoritesCount = favoritesSnapshot.documents.count
            
        } catch {
            print("Error loading stats: \(error)")
        }
        
        isLoadingStats = false
    }
}

// MARK: - Profile Card
private extension SettingsView {

    var profileCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                if let photoURL = authController.currentUser?.photoURL,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.green)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.green)
                }
            }
            
            Text(authController.currentUser?.displayName ?? "User")
                .font(.system(size: 20, weight: .semibold))
            
            Text(authController.currentUser?.email ?? "")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            HStack(spacing: 32) {
                profileStat(number: "\(recipesCount)", label: "Recipes")
                profileStat(number: "\(ingredientsCount)", label: "Ingredients")
                profileStat(number: "\(favoritesCount)", label: "Favorites")
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
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

// MARK: - Section Header
private extension SettingsView {
    func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.horizontal)
    }
}

// MARK: - Logout Button
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

// MARK: - Reusable Row
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

// MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthController())
    }
}
