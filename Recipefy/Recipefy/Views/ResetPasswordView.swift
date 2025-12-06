//
//  ResetPasswordView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 11/30/25.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var recoveryEmail = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) var dismiss

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
                        SecureField("Enter your new password", text: $newPassword)
                    }

                    // MARK: - Confirm Password
                    LabeledField(label: "Confirm New Password", systemImage: "lock.fill") {
                        SecureField("Re-enter your new password", text: $confirmPassword)
                    }

                    // MARK: - Confirm Button
                    Button {
                        validatePasswordReset()
                    } label: {
                        Text("Update Password")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                    }

                    Spacer().frame(height: 20)

                    // MARK: - Forgot Password Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Forgot Your Password?")
                            .font(.system(size: 18, weight: .bold))
                        
                        LabeledField(label: "Recovery Email", systemImage: "envelope.fill") {
                            TextField("Enter your account email", text: $recoveryEmail)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        Button {
                            sendRecoveryEmail()
                        } label: {
                            Text("Send Password Reset Email")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.green)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.large)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Validation Logic
    func validatePasswordReset() {
        if newPassword != confirmPassword {
            alertMessage = "New passwords do not match."
            showAlert = true
            return
        }
        if currentPassword.isEmpty || newPassword.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        alertMessage = "Password successfully updated!"
        showAlert = true
    }

    func sendRecoveryEmail() {
        if recoveryEmail.isEmpty {
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }

        alertMessage = "A password recovery email has been sent!"
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
    }
}
