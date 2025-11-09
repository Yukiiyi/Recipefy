//
//  CameraManager.swift
//  Recipefy
//
//  Created by AI Assistant on 11/7/25.
//

import AVFoundation
import UIKit
import SwiftUI
import Combine

@MainActor
class CameraManager: NSObject, ObservableObject {
  @Published var isAuthorized = false
  @Published var isCameraUnavailable = false
  @Published var capturedImage: UIImage?
  
  // SIMULATOR SUPPORT: Remove this property to disable simulator features
  @Published var isSimulator = false
  
  let session = AVCaptureSession()
  private let photoOutput = AVCapturePhotoOutput()
  private var videoDeviceInput: AVCaptureDeviceInput?
  
  override init() {
    super.init()
    // SIMULATOR SUPPORT: Remove this block to disable simulator detection
    isSimulator = SimulatorCameraSupport.isRunningOnSimulator
  }
  
  func checkAuthorization() async {
    // SIMULATOR SUPPORT: Remove this block to disable simulator authorization bypass
    if SimulatorCameraSupport.isRunningOnSimulator {
      isAuthorized = true
      print("📱 Running on Simulator - Camera authorization bypassed")
      return
    }
    
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      isAuthorized = true
      await setupCamera()
    case .notDetermined:
      let granted = await AVCaptureDevice.requestAccess(for: .video)
      if granted {
        isAuthorized = true
        await setupCamera()
      } else {
        isAuthorized = false
      }
    case .denied, .restricted:
      isAuthorized = false
    @unknown default:
      isAuthorized = false
    }
  }
  
  private func setupCamera() async {
    guard !session.isRunning else { return }
    
    session.beginConfiguration()
    session.sessionPreset = .photo
    
    do {
      // Get default video device
      guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
        isCameraUnavailable = true
        session.commitConfiguration()
        return
      }
      
      let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
      
      if session.canAddInput(videoDeviceInput) {
        session.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
      }
      
      if session.canAddOutput(photoOutput) {
        session.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .balanced
      }
      
      session.commitConfiguration()
      
      // Start session on background thread
      let captureSession = session
      DispatchQueue.global(qos: .userInitiated).async {
        captureSession.startRunning()
      }
    } catch {
      print("Camera setup error: \(error.localizedDescription)")
      isCameraUnavailable = true
      session.commitConfiguration()
    }
  }
  
  func capturePhoto() {
    // SIMULATOR SUPPORT: Remove this block to disable simulator mock images
    if SimulatorCameraSupport.isRunningOnSimulator {
      capturedImage = SimulatorCameraSupport.generateMockIngredientImage()
      return
    }
    
    let settings = AVCapturePhotoSettings()
    photoOutput.capturePhoto(with: settings, delegate: self)
  }
  
  func stopSession() {
    let captureSession = session
    if captureSession.isRunning {
      DispatchQueue.global(qos: .userInitiated).async {
        captureSession.stopRunning()
      }
    }
  }
}

// AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
  nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error {
      print("Photo capture error: \(error.localizedDescription)")
      return
    }
    
    guard let imageData = photo.fileDataRepresentation(),
          let image = UIImage(data: imageData) else {
      print("Unable to create image from photo data")
      return
    }
    
    Task { @MainActor in
      self.capturedImage = image
    }
  }
}

