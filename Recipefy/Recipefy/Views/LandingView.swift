//
//  LandingView.swift
//  Recipefy
//
//  Created on 12/1/25.
//  Landing page shown before authentication
//

import SwiftUI
import AVKit

struct LandingView: View {
    @Binding var showLanding: Bool
    @State private var navigateToSignIn = false
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.98, blue: 0.97)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Recipefy")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    // Phone Mockup with Video
                    PhoneMockupView()
                        .padding(.horizontal, 40)
                    
                    // Tagline
                    VStack(spacing: 4) {
                        Text("Make Food")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primary)
                        Text("With Wasted Food")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    
                    // Get Started Button
                    Button {
                        // Dismiss landing page and go to AuthView
                        showLanding = false
                        navigateToSignIn = false
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    
                    // Sign In Link
                    HStack(spacing: 4) {
                        Text("Already have an account ?")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        Button {
                            // Go to sign in mode
                            showLanding = false
                            navigateToSignIn = true
                        } label: {
                            Text("Sign in")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.36, green: 0.72, blue: 0.36))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 50)
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

// Phone Mockup with Video Placeholder
struct PhoneMockupView: View {
    var body: some View {
        ZStack {
            // Phone outer bezel (black frame with notch)
            ZStack {
                // Main phone body
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.black)
                    .frame(height: 440)
                
                // Screen area
                RoundedRectangle(cornerRadius: 36)
                    .fill(Color.white)
                    .frame(height: 425)
                    .padding(.horizontal, 4)
                
                // Notch at top
                VStack {
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 120, height: 25)
                        .offset(y: 2)
                    Spacer()
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
            
            // Screen Content (camera interface)
            VideoPlaceholderView()
                .frame(height: 410)
                .padding(.horizontal, 8)
                .clipShape(RoundedRectangle(cornerRadius: 34))
                .padding(.horizontal, 4)
        }
    }
}

// Video Placeholder (will be replaced with actual video/camera screenshot)
struct VideoPlaceholderView: View {
    var body: some View {
        ZStack {
            // Camera interface mockup background
            Color.black.opacity(0.9)
            
            // Center content - simulating camera view with food
            VStack {
                // Status bar area
                HStack {
                    Text("2:10")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "cellularbars")
                            .font(.system(size: 10))
                        Image(systemName: "wifi")
                            .font(.system(size: 10))
                        Image(systemName: "battery.100")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Camera viewfinder with scanning frame
                ZStack {
                    // Simulated camera feed background
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.gray.opacity(0.4),
                                    Color.gray.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Scanning frame corners
                    ZStack {
                        ScanningCorner(rotation: 0)
                            .position(x: 50, y: 50)
                        ScanningCorner(rotation: 90)
                            .position(x: 230, y: 50)
                        ScanningCorner(rotation: 270)
                            .position(x: 50, y: 230)
                        ScanningCorner(rotation: 180)
                            .position(x: 230, y: 230)
                    }
                    .frame(width: 280, height: 280)
                    
                    // Scan Food button
                    VStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 14))
                            Text("Scan Food")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.bottom, 16)
                    }
                }
                .frame(maxHeight: 300)
                
                Spacer()
                
                // Camera controls at bottom
                HStack(spacing: 50) {
                    Image(systemName: "bolt.slash.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Shutter button
                    ZStack {
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                    }
                    
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// Scanning corner overlay
struct ScanningCorner: View {
    let rotation: Double
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 0))
        }
        .stroke(Color.white, lineWidth: 3)
        .frame(width: 30, height: 30)
        .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    LandingView(showLanding: .constant(true))
}

