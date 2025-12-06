//
//  TermsOfServiceView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 11/30/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Section 1
                    SectionHeader(text: "1. Introduction")
                    
                    bodyText("""
                    Welcome to Recipefy, an app designed to provide personalized recipe suggestions based on ingredients you have on hand. By accessing and using the Recipefy mobile application (the "App"), you agree to comply with these Terms of Service ("Terms"). Please read them carefully.
                    """)

                    // MARK: - Section 2
                    SectionHeader(text: "2. Acceptance of Terms")

                    bodyText("""
                    By using the App, you acknowledge that you have read, understood, and agree to be bound by these Terms. If you do not agree to these Terms, you must immediately stop using the App.
                    """)

                    // MARK: - Section 3
                    SectionHeader(text: "3. Account Registration")

                    bodyText("""
                    To access certain features of the App, you may need to create an account. You must provide accurate and complete information when registering and agree to keep your account details updated and secure at all times.
                    """)

                    // MARK: - Section 4
                    SectionHeader(text: "4. Privacy Policy")

                    bodyText("""
                    Your privacy is important to us. Please refer to our Privacy Policy for details about how your information is collected, used, and protected.
                    """)

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Body Text Builder
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
        TermsOfServiceView()
    }
}
