//
//  PreferencesView.swift
//  Recipefy
//
//  Created on 12/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PreferencesView: View {
    @Environment(\.dismiss) var dismiss
    
    // State for preferences
    @State private var selectedDietTypes: Set<DietType> = []  // Changed to Set for multi-select
    @State private var selectedAllergies: Set<AllergyType> = []
    @State private var dislikes: [String] = []
    @State private var maxCookingTime: Double = 60
    @State private var newDislike: String = ""
    
    // Loading/saving state
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var showSaveSuccess = false
    
    let greenColor = Color(red: 0.36, green: 0.72, blue: 0.36)
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.97)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("Loading preferences...")
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Diet Type Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Diet Types")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Select all that apply to you")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            // Diet type pills (multi-select) - 6 options in 3 rows of 2
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    dietTypePill(.vegetarian)
                                    dietTypePill(.vegan)
                                }
                                HStack(spacing: 10) {
                                    dietTypePill(.pescatarian)
                                    dietTypePill(.glutenFree)
                                }
                                HStack(spacing: 10) {
                                    dietTypePill(.dairyFree)
                                    dietTypePill(.lowCarb)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // MARK: - Allergies Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Allergies")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Select all that apply - we'll avoid these completely")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            // Allergy toggles
                            VStack(spacing: 10) {
                                ForEach(AllergyType.allCases.chunked(into: 3), id: \.self) { row in
                                    HStack(spacing: 10) {
                                        ForEach(row, id: \.self) { allergy in
                                            allergyToggle(allergy)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // MARK: - Dislikes Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dislikes")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Add ingredients you prefer to avoid")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            // Dislike chips display
                            if !dislikes.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(dislikes, id: \.self) { dislike in
                                        dislikeChip(dislike)
                                    }
                                }
                                .padding(.bottom, 8)
                            }
                            
                            // Text field to add new dislikes
                            HStack {
                                TextField("Type ingredient name...", text: $newDislike)
                                    .textFieldStyle(.plain)
                                    .autocorrectionDisabled(false)
                                    .textInputAutocapitalization(.words)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .onSubmit {
                                        addDislike()
                                    }
                                
                                Button(action: addDislike) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(greenColor)
                                }
                                .disabled(newDislike.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // MARK: - Max Cooking Time Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Max Cooking Time")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(Int(maxCookingTime)) min")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(greenColor)
                            }
                            
                            Text("Maximum time you want to spend cooking")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Slider(value: $maxCookingTime, in: 15...60, step: 5)
                                .tint(greenColor)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        
                        // MARK: - Save Button
                        Button {
                            savePreferences()
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Save Preferences")
                                }
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(greenColor)
                            .cornerRadius(12)
                        }
                        .disabled(isSaving)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle("Dietary Preferences")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadPreferences()
        }
        .alert("Preferences Saved!", isPresented: $showSaveSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your dietary preferences have been updated.")
        }
    }
    
    // MARK: - Diet Type Pill (Multi-Select)
    private func dietTypePill(_ dietType: DietType) -> some View {
        Button {
            if selectedDietTypes.contains(dietType) {
                selectedDietTypes.remove(dietType)
            } else {
                selectedDietTypes.insert(dietType)
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: dietType.icon)
                    .font(.system(size: 14))
                Text(dietType.displayName)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(selectedDietTypes.contains(dietType) ? .white : greenColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(selectedDietTypes.contains(dietType) ? greenColor : greenColor.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Allergy Toggle
    private func allergyToggle(_ allergy: AllergyType) -> some View {
        Button {
            if selectedAllergies.contains(allergy) {
                selectedAllergies.remove(allergy)
            } else {
                selectedAllergies.insert(allergy)
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: selectedAllergies.contains(allergy) ? "checkmark.circle.fill" : allergy.icon)
                    .font(.system(size: 20))
                Text(allergy.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(selectedAllergies.contains(allergy) ? .white : greenColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(selectedAllergies.contains(allergy) ? greenColor : greenColor.opacity(0.15))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Dislike Chip
    private func dislikeChip(_ dislike: String) -> some View {
        HStack(spacing: 6) {
            Text(dislike)
                .font(.system(size: 14, weight: .medium))
            
            Button {
                dislikes.removeAll { $0 == dislike }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(greenColor)
        .cornerRadius(20)
    }
    
    // MARK: - Add Dislike
    private func addDislike() {
        let trimmed = newDislike.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !dislikes.contains(trimmed) else { return }
        dislikes.append(trimmed)
        newDislike = ""
    }
    
    // MARK: - Load Preferences
    private func loadPreferences() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        let db = Firestore.firestore()
        
        do {
            let document = try await db.collection("users").document(uid).collection("preferences").document("dietary").getDocument()
            
            if let data = document.data(),
               let preferences = DietaryPreferences.fromFirestore(data) {
                selectedDietTypes = Set(preferences.dietTypes)
                selectedAllergies = Set(preferences.allergies)
                dislikes = preferences.dislikes
                maxCookingTime = Double(preferences.maxCookingTime)
            }
        } catch {
            print("Error loading preferences: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Save Preferences
    private func savePreferences() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        isSaving = true
        
        let preferences = DietaryPreferences(
            dietTypes: Array(selectedDietTypes),
            allergies: Array(selectedAllergies),
            dislikes: dislikes,
            maxCookingTime: Int(maxCookingTime)
        )
        
        let db = Firestore.firestore()
        
        Task {
            do {
                try await db.collection("users").document(uid).collection("preferences").document("dietary").setData(preferences.toFirestore())
                
                // Print to console for testing
                print("✅ SAVED PREFERENCES:")
                print(preferences.toPromptString())
                
                isSaving = false
                showSaveSuccess = true
            } catch {
                print("Error saving preferences: \(error)")
                isSaving = false
            }
        }
    }
}

// MARK: - Flow Layout (for wrapping chips)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, subviewSize.height)
                currentX += subviewSize.width + spacing
                size.width = max(size.width, currentX - spacing)
            }
            
            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}

// MARK: - Array Extension for Chunking
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    NavigationStack {
        PreferencesView()
    }
}

