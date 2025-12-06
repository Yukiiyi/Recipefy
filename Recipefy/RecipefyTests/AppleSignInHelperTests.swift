//
//  AppleSignInHelperTests.swift
//  RecipefyTests
//
//  Unit tests for Apple Sign-In helper functions
//

import Testing
import Foundation
@testable import Recipefy

struct AppleSignInHelperTests {
  
  // MARK: - randomNonceString Tests
  
  @Test("randomNonceString generates string of default length 32")
  func randomNonceString_defaultLength_is32() {
    let nonce = randomNonceString()
    
    #expect(nonce.count == 32)
  }
  
  @Test("randomNonceString generates string of custom length")
  func randomNonceString_customLength_works() {
    let nonce16 = randomNonceString(length: 16)
    let nonce64 = randomNonceString(length: 64)
    let nonce1 = randomNonceString(length: 1)
    
    #expect(nonce16.count == 16)
    #expect(nonce64.count == 64)
    #expect(nonce1.count == 1)
  }
  
  @Test("randomNonceString uses valid characters only")
  func randomNonceString_validCharacters_only() {
    let validCharset = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    
    // Generate multiple nonces to test
    for _ in 0..<10 {
      let nonce = randomNonceString(length: 64)
      
      for char in nonce {
        #expect(validCharset.contains(char), "Invalid character found: \(char)")
      }
    }
  }
  
  @Test("randomNonceString generates unique values")
  func randomNonceString_generatesUniqueValues() {
    var nonces = Set<String>()
    
    // Generate 100 nonces and check they're all unique
    for _ in 0..<100 {
      let nonce = randomNonceString()
      nonces.insert(nonce)
    }
    
    #expect(nonces.count == 100, "All nonces should be unique")
  }
  
  @Test("randomNonceString returns non-empty string")
  func randomNonceString_nonEmpty() {
    let nonce = randomNonceString()
    
    #expect(!nonce.isEmpty)
  }
  
  // MARK: - sha256 Tests
  
  @Test("sha256 produces correct hash length")
  func sha256_correctLength_64chars() {
    let hash = sha256("test input")
    
    // SHA256 produces 64 hex characters (256 bits = 32 bytes = 64 hex chars)
    #expect(hash.count == 64)
  }
  
  @Test("sha256 produces only hex characters")
  func sha256_onlyHexCharacters() {
    let hash = sha256("any input string")
    let hexCharset = Set("0123456789abcdef")
    
    for char in hash {
      #expect(hexCharset.contains(char), "Non-hex character found: \(char)")
    }
  }
  
  @Test("sha256 is deterministic - same input produces same output")
  func sha256_deterministic_sameOutput() {
    let input = "consistent input"
    
    let hash1 = sha256(input)
    let hash2 = sha256(input)
    let hash3 = sha256(input)
    
    #expect(hash1 == hash2)
    #expect(hash2 == hash3)
  }
  
  @Test("sha256 different inputs produce different outputs")
  func sha256_differentInputs_differentOutputs() {
    let hash1 = sha256("input one")
    let hash2 = sha256("input two")
    let hash3 = sha256("input three")
    
    #expect(hash1 != hash2)
    #expect(hash2 != hash3)
    #expect(hash1 != hash3)
  }
  
  @Test("sha256 handles empty string")
  func sha256_emptyString_works() {
    let hash = sha256("")
    
    // Empty string should still produce a valid 64-char hash
    #expect(hash.count == 64)
    // Known SHA256 of empty string
    #expect(hash == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
  }
  
  @Test("sha256 handles special characters")
  func sha256_specialCharacters_works() {
    let hash = sha256("!@#$%^&*()_+-=[]{}|;':\",./<>?`~")
    
    #expect(hash.count == 64)
  }
  
  @Test("sha256 handles unicode characters")
  func sha256_unicodeCharacters_works() {
    let hash = sha256("Hello 世界 🌍 émoji")
    
    #expect(hash.count == 64)
  }
  
  @Test("sha256 handles long strings")
  func sha256_longString_works() {
    let longString = String(repeating: "a", count: 10000)
    let hash = sha256(longString)
    
    #expect(hash.count == 64)
  }
  
  @Test("sha256 produces lowercase hex")
  func sha256_lowercaseHex() {
    let hash = sha256("test")
    
    // Verify no uppercase letters
    #expect(hash == hash.lowercased())
  }
  
  // MARK: - Integration Test
  
  @Test("randomNonceString and sha256 work together for Apple Sign-In flow")
  func nonceAndHash_workTogether() {
    // This is how they're used in Apple Sign-In
    let nonce = randomNonceString()
    let hashedNonce = sha256(nonce)
    
    // Nonce should be 32 chars
    #expect(nonce.count == 32)
    
    // Hashed nonce should be 64 hex chars
    #expect(hashedNonce.count == 64)
    
    // Hash should be deterministic for the same nonce
    #expect(sha256(nonce) == hashedNonce)
  }
}

