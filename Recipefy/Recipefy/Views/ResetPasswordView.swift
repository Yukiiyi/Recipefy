//
//  ResetPasswordView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 11/30/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var recoveryEmail = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Notice"
    @State private var isLoading = false
    @State private var shouldDismissOnOK = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Current Password
                    LabeledField(label: "Current Password", systemImage: "lock.fill") {
                        SecureField("Enter your current password", text: $currentPassword)
                    }

                    // MARK: - New Password
                    LabeledField(label: "New Password", systemImage: "lock.fill") {
                        SecureField("Enter your new password (min 6 chars)", text: $newPassword)
                    }

                    // MARK: - Confirm Password
                    LabeledField(label: "Confirm New Password", systemImage: "lock.fill") {
                        SecureField("Re-enter your new password", text: $confirmPassword)
                    }

                    // MARK: - Update Password Button
                    Button {
                        Task {
                            await updatePassword()
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Update Password")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canUpdatePassword ? Color.green : Color.gray)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                    }
                    .disabled(!canUpdatePassword || isLoading)

                    Spacer().frame(height: 20)

                    // MARK: - Forgot Password Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Forgot Your Password?")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("We'll send you a link to reset your password via email.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        LabeledField(label: "Recovery Email", systemImage: "envelope.fill") {
                            TextField("Enter your account email", text: $recoveryEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        Button {
                            Task {
                                await sendRecoveryEmail()
                            }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text("Send Password Reset Email")
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(recoveryEmail.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                        }
                        .disabled(recoveryEmail.isEmpty || isLoading)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Pre-fill recovery email with current user's email
            recoveryEmail = authController.currentUser?.email ?? ""
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                if shouldDismissOnOK {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Computed Properties
    private var canUpdatePassword: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmPassword.isEmpty &&
        newPassword.count >= 6
    }

    // MARK: - Update Password
    private func updatePassword() async {
        // Validate inputs
        if newPassword != confirmPassword {
            alertTitle = "Error"
            alertMessage = "New passwords do not match."
            showAlert = true
            return
        }
        
        if newPassword.count < 6 {
            alertTitle = "Error"
            alertMessage = "Password must be at least 6 characters."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let success = await authController.updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
        
        isLoading = false
        
        if success {
            alertTitle = "Success"
            alertMessage = "Your password has been updated successfully!"
            shouldDismissOnOK = true
        } else {
            alertTitle = "Error"
            alertMessage = authController.errorMessage ?? "Failed to update password. Please check your current password."
            shouldDismissOnOK = false
        }
        showAlert = true
    }

    // MARK: - Send Recovery Email
    private func sendRecoveryEmail() async {
        if recoveryEmail.isEmpty {
            alertTitle = "Error"
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }
        
        isLoading = true
        
        let success = await authController.sendPasswordReset(to: recoveryEmail)
        
        isLoading = false
        
        if success {
            alertTitle = "Email Sent"
            alertMessage = "A password reset link has been sent to \(recoveryEmail). Check your inbox."
            shouldDismissOnOK = false
        } else {
            alertTitle = "Error"
            alertMessage = authController.errorMessage ?? "Failed to send reset email. Please check the email address."
            shouldDismissOnOK = false
        }
        showAlert = true
    }
}

// MARK: - Reusable Field Component
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
    NavigationStack {
        ResetPasswordView()
            .environmentObject(AuthController())
    }
}
