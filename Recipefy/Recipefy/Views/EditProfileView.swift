//
//  EditProfileView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 11/29/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    @State private var hasChanges = false
    
    private var originalUsername: String {
        authController.currentUser?.displayName ?? ""
    }
    
    private var originalEmail: String {
        authController.currentUser?.email ?? ""
    }
    
    // Check if user signed in with email (can change password and email)
    private var canChangePassword: Bool {
        authController.currentUser?.authProvider == .email
    }
    
    private var canChangeEmail: Bool {
        authController.currentUser?.authProvider == .email
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Back Button
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Back")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.green)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    VStack(spacing: 12) {
                        Text("Edit Profile")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 40)
                            .padding(.bottom, 10)
                        
                        // Profile Photo
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            if let photoURL = authController.currentUser?.photoURL,
                               let url = URL(string: photoURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
                            }
                        }
                        
                        // Auth Provider Badge
                        if let provider = authController.currentUser?.authProvider {
                            HStack(spacing: 4) {
                                Image(systemName: providerIcon(for: provider))
                                    .font(.system(size: 12))
                                Text("Signed in with \(providerName(for: provider))")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.secondary)
                        }
                    }

                    // Form Section for Profile
                    LabeledField(label: "Display Name", systemImage: "person.fill") {
                        TextField("Enter your name", text: $username)
                            .autocapitalization(.words)
                            .onChange(of: username) { _, _ in
                                updateHasChanges()
                            }
                    }

                    LabeledField(label: "Email", systemImage: "envelope.fill") {
                        if canChangeEmail {
                            TextField("your.email@example.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .onChange(of: email) { _, _ in
                                    updateHasChanges()
                                }
                        } else {
                            // Read-only email for Google/Apple users
                            Text(email)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Note about email changes (only for email auth users)
                    if canChangeEmail && email != originalEmail && !email.isEmpty {
                        Text("A verification email will be sent to confirm the new email address.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                    
                    // Explanation for OAuth users
                    if !canChangeEmail {
                        Text("Email is managed by your \(providerName(for: authController.currentUser?.authProvider ?? .email)) account and cannot be changed here.")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                    
                    // Reset Password - only for email auth
                    if canChangePassword {
                        NavigationLink(destination: ResetPasswordView()) {
                            Text("Reset Password")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 4)
                        }
                    }
                    
                    Spacer().frame(height: 80)
                    
                    // Save Changes Button
                    Button {
                        Task {
                            await saveChanges()
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Save Profile")
                        }
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(hasChanges ? Color.green : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!hasChanges || isSaving)
                    .padding(.horizontal)

                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Initialize form with current user data
            username = authController.currentUser?.displayName ?? ""
            email = authController.currentUser?.email ?? ""
        }
        .alert("Profile Update", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Helper to check if there are changes
    private func updateHasChanges() {
        let nameChanged = username != originalUsername
        let emailChanged = canChangeEmail && email != originalEmail
        hasChanges = nameChanged || emailChanged
    }
    
    // MARK: - Save Changes
    private func saveChanges() async {
        isSaving = true
        
        var success = true
        var messages: [String] = []
        
        // Update display name if changed
        if username != originalUsername && !username.isEmpty {
            let result = await authController.updateDisplayName(to: username)
            if result {
                messages.append("Name updated")
            } else {
                success = false
                messages.append(authController.errorMessage ?? "Failed to update name")
            }
        }
        
        // Update email if changed (only for email auth users)
        if canChangeEmail && email != originalEmail && !email.isEmpty {
            let result = await authController.updateEmail(to: email)
            if result {
                messages.append("Verification email sent to \(email)")
            } else {
                success = false
                messages.append(authController.errorMessage ?? "Failed to update email")
            }
        }
        
        isSaving = false
        
        if messages.isEmpty {
            alertMessage = "No changes to save"
        } else if success {
            alertMessage = "Profile updated successfully!\n" + messages.joined(separator: "\n")
        } else {
            alertMessage = messages.joined(separator: "\n")
        }
        showAlert = true
    }
    
    // MARK: - Helper Functions
    private func providerIcon(for provider: AppUser.AuthProvider) -> String {
        switch provider {
        case .email: return "envelope.fill"
        case .apple: return "apple.logo"
        case .google: return "g.circle.fill"
        }
    }
    
    private func providerName(for provider: AppUser.AuthProvider) -> String {
        switch provider {
        case .email: return "Email"
        case .apple: return "Apple"
        case .google: return "Google"
        }
    }
}

private struct LabeledField<Content: View>: View {
    let label: String
    let systemImage: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
                    .frame(width: 20)
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthController())
}
