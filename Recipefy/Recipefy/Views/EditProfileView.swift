//
//  EditProfileView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 11/29/25.
//

import SwiftUI

struct EditProfileView: View {
    @State private var username = "SampleUser"
    @State private var email = "sampleUser@andrew.cmu.edu"
    @State private var password = "123456"
    @State private var confirmPassword = "123456"
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    
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
                        
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
                        }
                        
                    }

                    // Form Section for Profile
                    LabeledField(label: "Username", systemImage: "person.fill") {
                        TextField("Enter your username", text: $username)
                            .autocapitalization(.none)
                    }

                    LabeledField(label: "Email", systemImage: "envelope.fill") {
                        TextField("your.email@example.com", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                        
                    Button {
                        if password != confirmPassword {
                            showAlert = true
                        } else {
                            // Handle Save Logic
                            // E.g., update the user profile with new data
                        }
                    } label: {
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
                                .shadow(color: .gray.opacity(1), radius: 4, x: 0, y: 4)
                        }
                    }
                    
                    Spacer().frame(height: 140)
                    
                    // Save Changes Button
                    Button {
                        // Handle Save Logic
                    } label: {
                        Text("Save Profile")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                            
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)

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
}