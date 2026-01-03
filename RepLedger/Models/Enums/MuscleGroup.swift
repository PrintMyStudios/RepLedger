import Foundation

/// Primary muscle groups for exercise categorization
enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    // Upper body - push
    case chest
    case shoulders
    case triceps

    // Upper body - pull
    case back
    case biceps
    case forearms

    // Lower body
    case quadriceps
    case hamstrings
    case glutes
    case calves

    // Core
    case core

    // Full body
    case fullBody

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .shoulders: return "Shoulders"
        case .triceps: return "Triceps"
        case .back: return "Back"
        case .biceps: return "Biceps"
        case .forearms: return "Forearms"
        case .quadriceps: return "Quadriceps"
        case .hamstrings: return "Hamstrings"
        case .glutes: return "Glutes"
        case .calves: return "Calves"
        case .core: return "Core"
        case .fullBody: return "Full Body"
        }
    }

    /// SF Symbol for the muscle group
    var icon: String {
        switch self {
        case .chest: return "figure.arms.open"
        case .shoulders: return "figure.boxing"
        case .triceps: return "figure.arms.open"
        case .back: return "figure.climbing"
        case .biceps: return "figure.arms.open"
        case .forearms: return "hand.raised.fill"
        case .quadriceps: return "figure.walk"
        case .hamstrings: return "figure.run"
        case .glutes: return "figure.step.training"
        case .calves: return "figure.walk"
        case .core: return "figure.core.training"
        case .fullBody: return "figure.strengthtraining.traditional"
        }
    }

    /// Groups muscle groups by body region for organized display
    static var grouped: [(title: String, groups: [MuscleGroup])] {
        [
            ("Push", [.chest, .shoulders, .triceps]),
            ("Pull", [.back, .biceps, .forearms]),
            ("Legs", [.quadriceps, .hamstrings, .glutes, .calves]),
            ("Core & Full Body", [.core, .fullBody])
        ]
    }
}
