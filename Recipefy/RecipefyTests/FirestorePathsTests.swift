//
//  FirestorePathsTests.swift
//  RecipefyTests
//
//  Tests for Firestore path helpers
//

import Testing
import Foundation
@testable import Recipefy

struct FirestorePathsTests {
  
  @Test("FirestorePaths.scans returns correct collection name")
  func firestorePaths_scans_correct() {
    #expect(FirestorePaths.scans == "scans")
  }
  
  @Test("FirestorePaths.scan() generates correct document path")
  func firestorePaths_scan_generatesPath() {
    let path = FirestorePaths.scan("test-id-123")
    
    #expect(path == "scans/test-id-123")
  }
  
  @Test("FirestorePaths.scan() handles empty ID")
  func firestorePaths_scan_emptyId() {
    let path = FirestorePaths.scan("")
    
    #expect(path == "scans/")
  }
  
  @Test("FirestorePaths.scan() handles special characters")
  func firestorePaths_scan_specialCharacters() {
    let path = FirestorePaths.scan("scan-123-abc_XYZ")
    
    #expect(path == "scans/scan-123-abc_XYZ")
  }
  
  @Test("FirestorePaths.scan() handles long IDs")
  func firestorePaths_scan_longId() {
    let longId = String(repeating: "a", count: 100)
    let path = FirestorePaths.scan(longId)
    
    #expect(path.hasPrefix("scans/"))
    #expect(path.hasSuffix(longId))
  }
}

