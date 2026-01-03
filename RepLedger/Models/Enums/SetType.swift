import Foundation

/// Types of sets for categorization and display
enum SetType: String, Codable, CaseIterable, Identifiable {
    case warmup
    case working
    case dropset
    case failure

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .warmup: return "Warm-up"
        case .working: return "Working"
        case .dropset: return "Drop Set"
        case .failure: return "To Failure"
        }
    }

    /// Short label for compact display
    var shortLabel: String {
        switch self {
        case .warmup: return "W"
        case .working: return ""  // Default, no label needed
        case .dropset: return "D"
        case .failure: return "F"
        }
    }

    /// Color key for theming (to be used with theme colors)
    var colorKey: String {
        switch self {
        case .warmup: return "textSecondary"
        case .working: return "text"
        case .dropset: return "warning"
        case .failure: return "error"
        }
    }
}
