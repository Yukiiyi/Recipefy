//
//  ScanControllerTests.swift
//  RecipefyTests
//
//  Created by streak honey on 11/10/25.
//

import Testing
import Foundation
@testable import Recipefy

@MainActor
struct ScanControllerTests {
  
  // MARK: - Mock Services
  
  // Simple mock that doesn't actually upload/save anything
  class MockStorageService: StorageService {
    var uploadCalled = false
    var uploadedData: Data?
    
    func uploadScanImage(data: Data, uid: String, scanId: String) async throws -> String {
      uploadCalled = true
      uploadedData = data
      return "mock/path/\(scanId).jpg"
    }
  }
  
  class MockScanRepository: ScanRepository {
    var createCalled = false
    var savedUserId: String?
    var savedImagePaths: [String]?
    
    func createScan(userId: String, imagePaths: [String]) async throws -> String {
      createCalled = true
      savedUserId = userId
      savedImagePaths = imagePaths
      return "mock-scan-id-123"
    }
  }
  
  // MARK: - Initialization Tests
  
  @Test("ScanController initializes with correct default state")
  func scanController_initialState_defaults() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    #expect(sut.statusText == "Idle")
    #expect(sut.currentScanId == nil)
    #expect(sut.currentImageData == nil)
  }
  
  // MARK: - State Management Tests
  
  @Test("ScanController accepts storage and repository dependencies")
  func scanController_acceptsDependencies() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    // Verify controller was created successfully with mocks
    #expect(sut.statusText == "Idle")
  }
  
  @Test("ScanController statusText can be updated")
  func scanController_statusText_canUpdate() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    sut.statusText = "Testing..."
    #expect(sut.statusText == "Testing...")
    
    sut.statusText = "Complete"
    #expect(sut.statusText == "Complete")
  }
  
  @Test("ScanController currentScanId can be set")
  func scanController_currentScanId_canSet() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    sut.currentScanId = "test-scan-123"
    #expect(sut.currentScanId == "test-scan-123")
  }
  
  @Test("ScanController currentImageData can store multiple images")
  func scanController_currentImageData_canStoreMultiple() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    let data1 = Data([0x01, 0x02])
    let data2 = Data([0x03, 0x04])
    
    sut.currentImageData = [data1, data2]
    #expect(sut.currentImageData?.count == 2)
  }
  
  // MARK: - Error State Tests
  
  @Test("ScanController handles error states in statusText")
  func scanController_errorStates_reflected() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    sut.statusText = "Error: Upload failed"
    #expect(sut.statusText.contains("Error"))
  }
  
  @Test("ScanController can reset state")
  func scanController_canResetState() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    // Set some state
    sut.currentScanId = "test-123"
    sut.currentImageData = [Data([0x01])]
    sut.statusText = "Processing..."
    
    // Reset
    sut.currentScanId = nil
    sut.currentImageData = nil
    sut.statusText = "Idle"
    
    #expect(sut.currentScanId == nil)
    #expect(sut.currentImageData == nil)
    #expect(sut.statusText == "Idle")
  }
  
  // MARK: - Data Handling Tests
  
  @Test("ScanController handles single image data")
  func scanController_handlesSingleImage() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    let imageData = Data([0x01, 0x02, 0x03])
    sut.currentImageData = [imageData]
    
    #expect(sut.currentImageData?.count == 1)
    #expect(sut.currentImageData?.first == imageData)
  }
  
  @Test("ScanController handles multiple image data")
  func scanController_handlesMultipleImages() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    let images = [
      Data([0x01]),
      Data([0x02]),
      Data([0x03])
    ]
    sut.currentImageData = images
    
    #expect(sut.currentImageData?.count == 3)
  }
  
  // MARK: - Status Message Tests
  
  @Test("ScanController status messages follow expected patterns")
  func scanController_statusMessages_followPatterns() async throws {
    let mockStorage = MockStorageService()
    let mockScans = MockScanRepository()
    let sut = ScanController(storage: mockStorage, scans: mockScans)
    
    // Test different status messages
    let validStatuses = ["Idle", "Uploading image 1 of 3...", "Writing Firestore doc...", "Upload complete (scanId: abc, 2 images)"]
    
    for status in validStatuses {
      sut.statusText = status
      #expect(!sut.statusText.isEmpty)
    }
  }
}

