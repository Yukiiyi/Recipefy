//
//  LandingView.swift
//  Recipefy
//
//  Created on 12/1/25.
//  Landing page shown before authentication
//

import SwiftUI
import AVKit
import AVFoundation

struct LandingView: View {
    @Binding var showLanding: Bool
    @EnvironmentObject var authController: AuthController
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background - adapts to dark/light mode
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title
                    Text("Recipefy")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    // Phone Mockup with Video - Fixed size, centered
                    PhoneMockupView()
                        .fixedSize() // Ensures phone stays exact size on all devices
                    
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
                    
                    // Get Started Button → Goes to Sign Up
                    Button {
                        authController.startInLoginMode = false  // Sign Up mode
                        showLanding = false
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primary)
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                    
                    // Sign In Link → Goes to Login
                    HStack(spacing: 4) {
                        Text("Already have an account ?")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                        
                        Button {
                            authController.startInLoginMode = true  // Login mode
                            showLanding = false
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

// Phone Mockup - FIXED size that stays the same on ALL devices
struct PhoneMockupView: View {
    // FIXED dimensions - will NOT change regardless of device
    private let phoneWidth: CGFloat = 220
    private let phoneHeight: CGFloat = 440
    private let bezelWidth: CGFloat = 8
    private let cornerRadius: CGFloat = 36
    
    var body: some View {
        ZStack {
            // Phone outer frame (black bezel)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.black)
                .frame(width: phoneWidth, height: phoneHeight)
                .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
            
            // Screen content - video fills the screen
            // Note: Video already contains its own Dynamic Island, so no overlay needed
            LandingPreviewView()
                .frame(width: phoneWidth - bezelWidth, height: phoneHeight - bezelWidth)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 4))
        }
        // Explicitly set fixed frame to prevent any scaling
        .frame(width: phoneWidth, height: phoneHeight)
    }
}

// Landing Preview - Tutorial Video Player (fills entire frame)
struct LandingPreviewView: View {
    @State private var player: AVPlayer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if let player = player {
                    // Use AVPlayerLayer for better control over video scaling
                    VideoPlayerView(player: player)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    // Fallback if video not found
                    VStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Loading...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        if let url = Bundle.main.url(forResource: "Recipify", withExtension: "mp4") {
            player = AVPlayer(url: url)
            player?.isMuted = true
            player?.play()
            
            // Loop video
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { _ in
                player?.seek(to: .zero)
                player?.play()
            }
        }
    }
}

// Custom video player view for better aspect ratio control
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(player: player)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    private var playerLayer: AVPlayerLayer?
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill // Fill the frame
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

#Preview {
    LandingView(showLanding: .constant(true))
        .environmentObject(AuthController())
}

