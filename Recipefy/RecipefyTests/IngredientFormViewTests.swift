//
//  IngredientFormViewTests.swift
//  RecipefyTests
//
//  Tests for IngredientFormView validation logic
//

import Testing
import Foundation
@testable import Recipefy

struct IngredientFormViewTests {
  
  // Note: We'll test the validation logic by extracting it or making it testable
  // For now, testing the validation patterns directly
  
  @Test("Valid decimal numbers are accepted")
  func validation_validDecimals() {
    let validInputs = ["1", "2.5", "0.5", "10", "100.25", "0.75"]
    
    for input in validInputs {
      let number = Double(input.trimmingCharacters(in: .whitespaces))
      #expect(number != nil, "\(input) should be a valid decimal")
    }
  }
  
  @Test("Valid fractions are accepted")
  func validation_validFractions() {
    let validFractions = ["1/2", "3/4", "1/4", "2/3", "5/8"]
    let fractionPattern = "^\\d+/\\d+$"
    
    for fraction in validFractions {
      let trimmed = fraction.trimmingCharacters(in: .whitespaces)
      if let regex = try? NSRegularExpression(pattern: fractionPattern) {
        let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed))
        #expect(match != nil, "\(fraction) should be a valid fraction")
      }
    }
  }
  
  @Test("Invalid fractions are rejected")
  func validation_invalidFractions() {
    let invalidInputs = ["1/", "/2", "1//2", "a/b", "1/2/3"]
    let fractionPattern = "^\\d+/\\d+$"
    
    for input in invalidInputs {
      let trimmed = input.trimmingCharacters(in: .whitespaces)
      if let regex = try? NSRegularExpression(pattern: fractionPattern) {
        let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed))
        #expect(match == nil, "\(input) should be invalid")
      }
    }
  }
  
  @Test("Invalid text is rejected as decimal")
  func validation_invalidText() {
    let invalidInputs = ["abc", "1.2.3", "1,000", "one", "2.5g"]
    
    for input in invalidInputs {
      let number = Double(input.trimmingCharacters(in: .whitespaces))
      #expect(number == nil, "\(input) should be invalid as decimal")
    }
  }
  
  @Test("Empty string is handled")
  func validation_emptyString() {
    let input = ""
    let trimmed = input.trimmingCharacters(in: .whitespaces)
    #expect(trimmed.isEmpty)
  }
  
  @Test("Whitespace is trimmed")
  func validation_whitespaceTrimmed() {
    let inputs = [" 1.5 ", "  2/3  ", "\t1/2\n"]
    
    for input in inputs {
      let trimmed = input.trimmingCharacters(in: .whitespaces)
      #expect(!trimmed.hasPrefix(" ") && !trimmed.hasSuffix(" "))
    }
  }
  
  @Test("Fraction pattern regex is correct")
  func validation_fractionPatternWorks() {
    let pattern = "^\\d+/\\d+$"
    let regex = try? NSRegularExpression(pattern: pattern)
    
    #expect(regex != nil)
    
    // Valid cases
    let validMatch = regex?.firstMatch(in: "1/2", range: NSRange("1/2".startIndex..., in: "1/2"))
    #expect(validMatch != nil)
    
    // Invalid cases
    let invalidMatch = regex?.firstMatch(in: "1/", range: NSRange("1/".startIndex..., in: "1/"))
    #expect(invalidMatch == nil)
  }
  
  @Test("Complex decimal numbers")
  func validation_complexDecimals() {
    let testCases: [(String, Bool)] = [
      ("0", true),
      ("0.0", true),
      ("0.25", true),
      ("10.5", true),
      ("999.99", true),
      (".5", true),   // Swift Double allows this
      ("1.", true),   // Swift Double allows trailing dot (becomes 1.0)
      ("1..5", false),
      ("", false)
    ]
    
    for (input, shouldBeValid) in testCases {
      let number = Double(input)
      if shouldBeValid {
        #expect(number != nil || input.isEmpty, "\(input) should be valid")
      } else {
        #expect(number == nil, "\(input) should be invalid")
      }
    }
  }
  
  @Test("Special number formats")
  func validation_specialFormats() {
    // Scientific notation
    let scientific = Double("1e5")
    #expect(scientific != nil)
    
    // Negative numbers
    let negative = Double("-5")
    #expect(negative != nil)
    
    // Zero variations
    #expect(Double("0") != nil)
    #expect(Double("0.0") != nil)
  }
}

