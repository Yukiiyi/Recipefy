//
//  CameraPreviewView.swift
//  Recipefy
//
//  Created by AI Assistant on 11/7/25.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
  let session: AVCaptureSession
  
  func makeUIView(context: Context) -> VideoPreviewUIView {
    let view = VideoPreviewUIView()
    view.previewLayer.session = session
    view.previewLayer.videoGravity = .resizeAspectFill
    return view
  }
  
  func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
    // No updates needed
  }
}

class VideoPreviewUIView: UIView {
  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }
  
  var previewLayer: AVCaptureVideoPreviewLayer {
    layer as! AVCaptureVideoPreviewLayer
  }
}

