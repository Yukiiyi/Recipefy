//
//  HelpAndSupportView.swift
//  Recipefy
//
//  Created by Abdallah Salam Sameer Abdaljalil on 12/1/25.
//

import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - FAQ Section
                    SectionHeader(text: "Frequently Asked Questions")
                    
                    VStack(spacing: 16) {
                        FAQItem(
                            question: "How do I reset my password?",
                            answer: "You can reset your password from the Edit Profile screen by tapping the Reset Password button."
                        )
                        
                        FAQItem(
                            question: "How do I save a recipe?",
                            answer: "Open a recipe and tap the heart icon to save it to your Saved Recipes list."
                        )
                        
                        FAQItem(
                            question: "How do dietary preferences work?",
                            answer: "Set your allergies and restrictions in the Dietary Preferences section to get recipe suggestions tailored to you."
                        )
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // MARK: - Contact Section
                    SectionHeader(text: "Contact Support")
                    
                    Text("If you're experiencing issues or have questions, feel free to reach out to us anytime.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                    
                    Button(action: {
                        sendEmail()
                    }) {
                        Text("Email Support")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 0, y: 4)
                    }
                    
                    Spacer().frame(height: 20)
                    
                    // MARK: - App Info Footer
                    VStack(spacing: 4) {
                        Text("Recipefy v1.0")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("© 2025 Recipefy. All rights reserved.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // Fake email action
    func sendEmail() {
        print("Open mail client (placeholder)")
    }
}

// MARK: - Section Header
private struct SectionHeader: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.primary)
    }
}

// MARK: - FAQ Item
private struct FAQItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(answer)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        HelpAndSupportView()
    }
}
