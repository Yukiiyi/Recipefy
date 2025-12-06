//
//  AuthView.swift
//  Recipefy
//
//  Created by abdallah abdaljalil on 11/06/25.
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var controller: AuthController
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoginMode = true
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var hasSetInitialMode = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Branding
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.36, green: 0.72, blue: 0.36).opacity(0.2))
                                .frame(width: 80, height: 80)
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
                        }
                        Text("Recipefy")
                            .font(.system(size: 32, weight: .bold))
                        Text("Turn ingredients into delicious meals")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)

                    // Mode toggle
                    Picker("", selection: $isLoginMode) {
                        Text("Log In").tag(true)
                        Text("Sign Up").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: isLoginMode) { _, _ in
                        username = ""
                        confirmPassword = ""
                        controller.errorMessage = nil
                    }

                    // Social buttons
                    VStack(spacing: 12) {
                        Button {
                        Task { await controller.signInWithGoogle() }
                    } label: {
                        HStack(spacing: 12) {
                            Image("google-logo")
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            Text(isLoginMode ? "Sign in with Google" : "Sign up with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity) 
                        .frame(height: 50)
                        .background(Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                        .accessibilityLabel(isLoginMode ? "Sign in with Google" : "Sign up with Google")
                    }
                    .buttonStyle(.plain)
                    .disabled(controller.isLoading)


                        SignInWithAppleButton(
                            onRequest: { request in
                                controller.prepareAppleSignInRequest(request)
                            },
                            onCompletion: { result in
                                Task { await controller.handleAppleSignIn(result: result) }
                            }
                        )
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 50)
                        .cornerRadius(12)
                        .disabled(controller.isLoading)
                        .id(colorScheme) // Forces button to recreate when mode changes
                    }
                    .padding(.horizontal)

                    // Separator
                    HStack {
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                        Text("Or")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(height: 1)
                    }
                    .padding(.horizontal)

                    // Form
                    VStack(alignment: .leading, spacing: 16) {
                        if !isLoginMode {
                            LabeledField(label: "Username", systemImage: "person.fill") {
                                TextField("Enter your username", text: $username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                            }
                        }

                        LabeledField(label: "Email", systemImage: "envelope.fill") {
                            TextField("Enter your email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        LabeledField(label: "Password", systemImage: "lock.fill") {
                            SecureField("Enter your password", text: $password)
                                .textContentType(isLoginMode ? .password : .newPassword)
                        }

                        if !isLoginMode {
                            LabeledField(label: "Confirm Password", systemImage: "lock.fill") {
                                SecureField("Enter your password again", text: $confirmPassword)
                                    .textContentType(.newPassword)
                            }
                        }

                        if let error = controller.errorMessage {
                            Text(error).foregroundColor(.red)
                        }

                        Button {
                            Task {
                                if !isLoginMode && password != confirmPassword {
                                    controller.errorMessage = "Passwords do not match"
                                    return
                                }
                                if isLoginMode {
                                    await controller.signIn(email: email, password: password)
                                } else {
                                    await controller.signUp(email: email, password: password, username: username)
                                }
                            }
                        } label: {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.36, green: 0.72, blue: 0.36))
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .disabled(controller.isLoading || email.isEmpty || password.isEmpty || (!isLoginMode && (username.isEmpty || confirmPassword.isEmpty)))
                        .opacity((email.isEmpty || password.isEmpty || (!isLoginMode && (username.isEmpty || confirmPassword.isEmpty))) ? 0.6 : 1.0)
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Set initial mode based on how user navigated from landing page
            if !hasSetInitialMode {
                isLoginMode = controller.startInLoginMode
                hasSetInitialMode = true
            }
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
    AuthView()
        .environmentObject(AuthController())
}
