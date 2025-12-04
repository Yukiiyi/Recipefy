//
//  PrivacyPolicyView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 12/1/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
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
                    

                    // MARK: - Title
                    Text("Privacy Policy")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)

                    // MARK: - Section 1
                    TOSectionHeader(text: "1. Introduction")

                    bodyText("""
                    Your privacy is important to us. This policy explains how Recipefy collects, uses, and protects your personal information. By using our app, you agree to the practices described below.
                    """)

                    Spacer()

                    // MARK: - Section 2
                    TOSectionHeader(text: "2. Information We Collect")

                    bodyText("""
                    We may collect personal details such as your name, email address, and usage data. Additionally, optional information like ingredient preferences or saved recipes may be used to improve your experience.
                    """)

                    Spacer()

                    // MARK: - Section 3
                    TOSectionHeader(text: "3. How We Use Your Information")

                    bodyText("""
                    We use your data to personalize recipes, improve our recommendations, secure your account, and enhance app performance. We do not sell or share your information with third parties.
                    """)

                    Spacer()

                    // MARK: - Section 4
                    TOSectionHeader(text: "4. Data Security")

                    bodyText("""
                    We implement industry-standard security practices to protect your data. However, no system is fully secure, and we encourage you to use strong passwords and keep your login details safe.
                    """)

                    Spacer()

                    // MARK: - Close Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Helper for body text
    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundColor(.secondary)
            .lineSpacing(6)
    }
}

// MARK: - Reusable Section Header
struct TOSectionHeader: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PrivacyPolicyView()
}