//
//  MeasurementUnitTests.swift
//  RecipefyTests
//
//  Created by streak honey on 12/2/25.
//

import Testing
import Foundation
@testable import Recipefy

struct MeasurementUnitTests {
  
  // MARK: - Basic Enum Tests
  
  @Test("MeasurementUnit has all expected cases")
  func measurementUnit_hasAllCases() {
    let allCases = MeasurementUnit.allCases
    
    #expect(allCases.count == 14)
    #expect(allCases.contains(.cup))
    #expect(allCases.contains(.tablespoon))
    #expect(allCases.contains(.teaspoon))
    #expect(allCases.contains(.fluidOunce))
    #expect(allCases.contains(.milliliter))
    #expect(allCases.contains(.liter))
    #expect(allCases.contains(.ounce))
    #expect(allCases.contains(.pound))
    #expect(allCases.contains(.gram))
    #expect(allCases.contains(.kilogram))
    #expect(allCases.contains(.whole))
    #expect(allCases.contains(.piece))
    #expect(allCases.contains(.clove))
    #expect(allCases.contains(.bunch))
  }
  
  // MARK: - Raw Value Tests
  
  @Test("MeasurementUnit raw values are correct")
  func measurementUnit_rawValues() {
    #expect(MeasurementUnit.cup.rawValue == "cup")
    #expect(MeasurementUnit.tablespoon.rawValue == "tbsp")
    #expect(MeasurementUnit.teaspoon.rawValue == "tsp")
    #expect(MeasurementUnit.fluidOunce.rawValue == "fl oz")
    #expect(MeasurementUnit.milliliter.rawValue == "ml")
    #expect(MeasurementUnit.liter.rawValue == "liter")
    #expect(MeasurementUnit.ounce.rawValue == "oz")
    #expect(MeasurementUnit.pound.rawValue == "lb")
    #expect(MeasurementUnit.gram.rawValue == "gram")
    #expect(MeasurementUnit.kilogram.rawValue == "kg")
    #expect(MeasurementUnit.whole.rawValue == "whole")
    #expect(MeasurementUnit.piece.rawValue == "piece")
    #expect(MeasurementUnit.clove.rawValue == "clove")
    #expect(MeasurementUnit.bunch.rawValue == "bunch")
  }
  
  // MARK: - Identifiable Tests
  
  @Test("MeasurementUnit id matches rawValue")
  func measurementUnit_id_matchesRawValue() {
    for unit in MeasurementUnit.allCases {
      #expect(unit.id == unit.rawValue)
    }
  }
  
  // MARK: - Display Name Tests
  
  @Test("MeasurementUnit displayName matches rawValue")
  func measurementUnit_displayName_matchesRawValue() {
    for unit in MeasurementUnit.allCases {
      #expect(unit.displayName == unit.rawValue)
    }
  }
  
  // MARK: - Volume Units Tests
  
  @Test("volumeUnits contains all volume measurements")
  func measurementUnit_volumeUnits_correct() {
    let volumeUnits = MeasurementUnit.volumeUnits
    
    #expect(volumeUnits.count == 6)
    #expect(volumeUnits.contains(.cup))
    #expect(volumeUnits.contains(.tablespoon))
    #expect(volumeUnits.contains(.teaspoon))
    #expect(volumeUnits.contains(.fluidOunce))
    #expect(volumeUnits.contains(.milliliter))
    #expect(volumeUnits.contains(.liter))
  }
  
  @Test("volumeUnits does not contain non-volume units")
  func measurementUnit_volumeUnits_excludesOthers() {
    let volumeUnits = MeasurementUnit.volumeUnits
    
    #expect(!volumeUnits.contains(.gram))
    #expect(!volumeUnits.contains(.whole))
    #expect(!volumeUnits.contains(.pound))
  }
  
  // MARK: - Weight Units Tests
  
  @Test("weightUnits contains all weight measurements")
  func measurementUnit_weightUnits_correct() {
    let weightUnits = MeasurementUnit.weightUnits
    
    #expect(weightUnits.count == 4)
    #expect(weightUnits.contains(.gram))
    #expect(weightUnits.contains(.kilogram))
    #expect(weightUnits.contains(.ounce))
    #expect(weightUnits.contains(.pound))
  }
  
  @Test("weightUnits does not contain non-weight units")
  func measurementUnit_weightUnits_excludesOthers() {
    let weightUnits = MeasurementUnit.weightUnits
    
    #expect(!weightUnits.contains(.cup))
    #expect(!weightUnits.contains(.whole))
    #expect(!weightUnits.contains(.teaspoon))
  }
  
  // MARK: - Count Units Tests
  
  @Test("countUnits contains all count measurements")
  func measurementUnit_countUnits_correct() {
    let countUnits = MeasurementUnit.countUnits
    
    #expect(countUnits.count == 4)
    #expect(countUnits.contains(.whole))
    #expect(countUnits.contains(.piece))
    #expect(countUnits.contains(.clove))
    #expect(countUnits.contains(.bunch))
  }
  
  @Test("countUnits does not contain non-count units")
  func measurementUnit_countUnits_excludesOthers() {
    let countUnits = MeasurementUnit.countUnits
    
    #expect(!countUnits.contains(.cup))
    #expect(!countUnits.contains(.gram))
    #expect(!countUnits.contains(.liter))
  }
  
  // MARK: - Unit Group Coverage Tests
  
  @Test("All units are in exactly one category")
  func measurementUnit_allUnitsInOneCategory() {
    let volume = Set(MeasurementUnit.volumeUnits)
    let weight = Set(MeasurementUnit.weightUnits)
    let count = Set(MeasurementUnit.countUnits)
    
    // Check no overlap
    #expect(volume.intersection(weight).isEmpty)
    #expect(volume.intersection(count).isEmpty)
    #expect(weight.intersection(count).isEmpty)
    
    // Check all units are covered
    let allGrouped = volume.union(weight).union(count)
    let allCases = Set(MeasurementUnit.allCases)
    #expect(allGrouped == allCases)
  }
  
  // MARK: - Codable Tests
  
  @Test("MeasurementUnit encodes to JSON correctly")
  func measurementUnit_encodesToJSON() throws {
    let unit = MeasurementUnit.cup
    let encoder = JSONEncoder()
    let data = try encoder.encode(unit)
    let jsonString = String(data: data, encoding: .utf8)
    
    #expect(jsonString == "\"cup\"")
  }
  
  @Test("MeasurementUnit decodes from JSON correctly")
  func measurementUnit_decodesFromJSON() throws {
    let jsonString = "\"gram\""
    let jsonData = try #require(jsonString.data(using: .utf8))
    let decoder = JSONDecoder()
    let unit = try decoder.decode(MeasurementUnit.self, from: jsonData)
    
    #expect(unit == .gram)
  }
  
  @Test("MeasurementUnit fails to decode invalid JSON")
  func measurementUnit_failsInvalidJSON() throws {
    let jsonString = "\"invalid_unit\""
    let jsonData = try #require(jsonString.data(using: .utf8))
    let decoder = JSONDecoder()
    
    #expect(throws: DecodingError.self) {
      _ = try decoder.decode(MeasurementUnit.self, from: jsonData)
    }
  }
}

