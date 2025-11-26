//
//  MeasurementUnit.swift
//  Recipefy
//
//  Created by streak honey on 11/25/25.
//

import Foundation

enum MeasurementUnit: String, CaseIterable, Identifiable, Codable {
    // Volume
    case cup = "cup"
    case tablespoon = "tbsp"
    case teaspoon = "tsp"
    case fluidOunce = "fl oz"
    case milliliter = "ml"
    case liter = "liter"

    // Weight
    case ounce = "oz"
    case pound = "lb"
    case gram = "gram"
    case kilogram = "kg"


    // Count
    case whole = "whole"
    case piece = "piece"
    case clove = "clove"
    case bunch = "bunch"

    var id: String { rawValue }

    /// Display name for UI
    var displayName: String { rawValue }

    /// All volume units
    static var volumeUnits: [MeasurementUnit] {
        [.cup, .tablespoon, .teaspoon, .fluidOunce, .milliliter, .liter]
    }

    /// All weight units
    static var weightUnits: [MeasurementUnit] {
        [.gram, .kilogram, .ounce, .pound]
    }

    /// All count units
    static var countUnits: [MeasurementUnit] {
        [.whole, .piece, .clove, .bunch]
    }
}

