import Foundation

/// Equipment types for exercise categorization and filtering
enum Equipment: String, Codable, CaseIterable, Identifiable {
    case barbell
    case dumbbell
    case kettlebell
    case machine
    case cable
    case bodyweight
    case bands
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .barbell: return "Barbell"
        case .dumbbell: return "Dumbbell"
        case .kettlebell: return "Kettlebell"
        case .machine: return "Machine"
        case .cable: return "Cable"
        case .bodyweight: return "Bodyweight"
        case .bands: return "Bands"
        case .other: return "Other"
        }
    }

    /// SF Symbol for the equipment type
    var icon: String {
        switch self {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .kettlebell: return "figure.strengthtraining.functional"
        case .machine: return "gearshape.fill"
        case .cable: return "arrow.left.and.right"
        case .bodyweight: return "figure.stand"
        case .bands: return "circle.dotted"
        case .other: return "ellipsis.circle"
        }
    }
}
