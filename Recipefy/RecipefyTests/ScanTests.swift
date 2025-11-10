//
//  ScanTests.swift
//  RecipefyTests
//
//  Created by streak honey on 11/10/25.
//

import Testing
import Foundation
@testable import Recipefy

@MainActor
struct ScanTests {
  
  // MARK: - Scan Model Tests
  
  @Test("Scan creation with all fields")
  func scan_creation_allFields() async throws {
    let now = Date()
    let scan = Scan(
      id: "test-scan-123",
      userId: "user-456",
      imagePaths: ["path/to/image1.jpg", "path/to/image2.jpg"],
      status: "uploaded",
      createdAt: now
    )
    
    #expect(scan.id == "test-scan-123")
    #expect(scan.userId == "user-456")
    #expect(scan.imagePaths.count == 2)
    #expect(scan.status == "uploaded")
    #expect(scan.createdAt == now)
  }
  
  @Test("Scan with nil id")
  func scan_creation_nilId() async throws {
    let scan = Scan(
      id: nil,
      userId: "user-123",
      imagePaths: ["path/image.jpg"],
      status: "processing",
      createdAt: Date()
    )
    
    #expect(scan.id == nil)
    #expect(scan.userId == "user-123")
  }
  
  @Test("Scan with single image path")
  func scan_singleImagePath() async throws {
    let scan = Scan(
      id: "scan-1",
      userId: "user-1",
      imagePaths: ["single/image.jpg"],
      status: "done",
      createdAt: Date()
    )
    
    #expect(scan.imagePaths.count == 1)
    #expect(scan.imagePaths.first == "single/image.jpg")
  }
  
  @Test("Scan with multiple image paths")
  func scan_multipleImagePaths() async throws {
    let paths = [
      "path/image1.jpg",
      "path/image2.jpg",
      "path/image3.jpg"
    ]
    
    let scan = Scan(
      id: "scan-multi",
      userId: "user-1",
      imagePaths: paths,
      status: "uploaded",
      createdAt: Date()
    )
    
    #expect(scan.imagePaths.count == 3)
    #expect(scan.imagePaths == paths)
  }
  
  @Test("Scan with empty image paths")
  func scan_emptyImagePaths() async throws {
    let scan = Scan(
      id: "scan-empty",
      userId: "user-1",
      imagePaths: [],
      status: "error",
      createdAt: Date()
    )
    
    #expect(scan.imagePaths.isEmpty)
  }
  
  // MARK: - Status Tests
  
  @Test("Scan status - uploaded")
  func scan_status_uploaded() async throws {
    let scan = Scan(
      id: "scan-1",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "uploaded",
      createdAt: Date()
    )
    
    #expect(scan.status == "uploaded")
  }
  
  @Test("Scan status - processing")
  func scan_status_processing() async throws {
    let scan = Scan(
      id: "scan-2",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "processing",
      createdAt: Date()
    )
    
    #expect(scan.status == "processing")
  }
  
  @Test("Scan status - done")
  func scan_status_done() async throws {
    let scan = Scan(
      id: "scan-3",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "done",
      createdAt: Date()
    )
    
    #expect(scan.status == "done")
  }
  
  @Test("Scan status - error")
  func scan_status_error() async throws {
    let scan = Scan(
      id: "scan-4",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "error",
      createdAt: Date()
    )
    
    #expect(scan.status == "error")
  }
  
  @Test("Scan status can be updated")
  func scan_status_canUpdate() async throws {
    var scan = Scan(
      id: "scan-1",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "uploaded",
      createdAt: Date()
    )
    
    #expect(scan.status == "uploaded")
    
    scan.status = "processing"
    #expect(scan.status == "processing")
    
    scan.status = "done"
    #expect(scan.status == "done")
  }
  
  // MARK: - Date Tests
  
  @Test("Scan stores creation timestamp")
  func scan_storesTimestamp() async throws {
    let now = Date()
    let scan = Scan(
      id: "scan-1",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "uploaded",
      createdAt: now
    )
    
    // Allow for tiny time differences due to test execution
    let timeDifference = abs(scan.createdAt.timeIntervalSince(now))
    #expect(timeDifference < 0.001) // Less than 1 millisecond
  }
  
  @Test("Scan timestamps are comparable")
  func scan_timestamps_comparable() async throws {
    let earlier = Date()
    let later = Date().addingTimeInterval(10)
    
    let scan1 = Scan(id: "1", userId: "user", imagePaths: [], status: "uploaded", createdAt: earlier)
    let scan2 = Scan(id: "2", userId: "user", imagePaths: [], status: "uploaded", createdAt: later)
    
    #expect(scan1.createdAt < scan2.createdAt)
  }
  
  // MARK: - Identifiable Conformance Tests
  
  @Test("Scan conforms to Identifiable")
  func scan_conformsToIdentifiable() async throws {
    let scan = Scan(
      id: "unique-id",
      userId: "user-1",
      imagePaths: ["path.jpg"],
      status: "done",
      createdAt: Date()
    )
    
    // Test that id property works with Identifiable
    let scans: [Scan] = [scan]
    #expect(scans.first?.id == "unique-id")
  }
  
  // MARK: - Edge Cases
  
  @Test("Scan with special characters in paths")
  func scan_specialCharactersInPaths() async throws {
    let scan = Scan(
      id: "scan-1",
      userId: "user-1",
      imagePaths: ["path/with spaces/image.jpg", "path/with-dashes/image.jpg"],
      status: "uploaded",
      createdAt: Date()
    )
    
    #expect(scan.imagePaths[0].contains(" "))
    #expect(scan.imagePaths[1].contains("-"))
  }
  
  @Test("Scan with long userId")
  func scan_longUserId() async throws {
    let longUserId = String(repeating: "a", count: 100)
    let scan = Scan(
      id: "scan-1",
      userId: longUserId,
      imagePaths: ["path.jpg"],
      status: "uploaded",
      createdAt: Date()
    )
    
    #expect(scan.userId.count == 100)
    #expect(scan.userId == longUserId)
  }
  
  @Test("Scan with many image paths")
  func scan_manyImagePaths() async throws {
    let manyPaths = (0..<10).map { "path/image\($0).jpg" }
    let scan = Scan(
      id: "scan-many",
      userId: "user-1",
      imagePaths: manyPaths,
      status: "uploaded",
      createdAt: Date()
    )
    
    #expect(scan.imagePaths.count == 10)
  }
}

