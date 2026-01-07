import Foundation

/// Weight units for lifting
enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case kg
    case lb

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kg: return "Kilograms"
        case .lb: return "Pounds"
        }
    }

    var abbreviation: String {
        switch self {
        case .kg: return "kg"
        case .lb: return "lb"
        }
    }

    /// Conversion factor to kilograms (canonical internal unit)
    var toKgFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lb: return 0.45359237
        }
    }

    /// Conversion factor from kilograms
    var fromKgFactor: Double {
        switch self {
        case .kg: return 1.0
        case .lb: return 2.20462262
        }
    }
}

/// Bodyweight display units (includes stone+lb option)
enum BodyweightUnit: String, Codable, CaseIterable, Identifiable {
    case kg
    case lb
    case stoneLb  // Stone and pounds (UK format)

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kg: return "Kilograms"
        case .lb: return "Pounds"
        case .stoneLb: return "Stone & Pounds"
        }
    }

    var abbreviation: String {
        switch self {
        case .kg: return "kg"
        case .lb: return "lb"
        case .stoneLb: return "st lb"
        }
    }

    /// Formats a weight value (stored in kg) for display in this unit
    func format(_ kgValue: Double) -> String {
        switch self {
        case .kg:
            return String(format: "%.1f kg", kgValue)
        case .lb:
            let lbValue = kgValue * WeightUnit.lb.fromKgFactor
            return String(format: "%.1f lb", lbValue)
        case .stoneLb:
            let totalLb = kgValue * WeightUnit.lb.fromKgFactor
            var stone = Int(totalLb / 14)
            let remainingLb = totalLb.truncatingRemainder(dividingBy: 14)
            var pounds = Int(remainingLb.rounded())
            // Handle edge case: if rounded pounds == 14, carry to next stone
            if pounds >= 14 {
                stone += 1
                pounds = 0
            }
            return "\(stone) st \(pounds) lb"
        }
    }
}

// MARK: - Conversion Utilities

extension Double {
    /// Convert from kilograms to specified unit
    func fromKg(to unit: WeightUnit) -> Double {
        self * unit.fromKgFactor
    }

    /// Convert from specified unit to kilograms
    func toKg(from unit: WeightUnit) -> Double {
        self * unit.toKgFactor
    }

    /// Format as weight string with unit
    func formatWeight(unit: WeightUnit, decimals: Int = 1) -> String {
        let converted = self.fromKg(to: unit)
        return String(format: "%.\(decimals)f \(unit.abbreviation)", converted)
    }
}
