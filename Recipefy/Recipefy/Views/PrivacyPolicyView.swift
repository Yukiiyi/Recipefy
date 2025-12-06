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
                    // MARK: - Section 1
                    SectionHeader(text: "1. Introduction")

                    bodyText("""
                    Your privacy is important to us. This policy explains how Recipefy collects, uses, and protects your personal information. By using our app, you agree to the practices described below.
                    """)

                    // MARK: - Section 2
                    SectionHeader(text: "2. Information We Collect")

                    bodyText("""
                    We may collect personal details such as your name, email address, and usage data. Additionally, optional information like ingredient preferences or saved recipes may be used to improve your experience.
                    """)

                    // MARK: - Section 3
                    SectionHeader(text: "3. How We Use Your Information")

                    bodyText("""
                    We use your data to personalize recipes, improve our recommendations, secure your account, and enhance app performance. We do not sell or share your information with third parties.
                    """)

                    // MARK: - Section 4
                    SectionHeader(text: "4. Data Security")

                    bodyText("""
                    We implement industry-standard security practices to protect your data. However, no system is fully secure, and we encourage you to use strong passwords and keep your login details safe.
                    """)

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.large)
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
private struct SectionHeader: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.primary)
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
