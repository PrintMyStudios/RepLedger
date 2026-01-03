import Foundation
import SwiftData

/// A workout template for quick-starting workouts.
/// Free users are limited to 3 templates; Pro unlocks unlimited.
@Model
final class Template {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Template name (e.g., "Push Day", "Upper Body")
    var name: String

    /// Ordered list of exercise IDs in this template
    /// Stored as array for ordering; references Exercise entities by ID
    var orderedExerciseIds: [UUID]

    /// Creation timestamp
    var createdAt: Date

    /// Last time this template was used to start a workout
    var lastUsedAt: Date?

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        orderedExerciseIds: [UUID] = [],
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.orderedExerciseIds = orderedExerciseIds
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
    }
}

// MARK: - Template Gating

extension Template {
    /// Maximum templates allowed for free users
    static let freeLimit = 3

    /// Check if user can create a new template (for paywall gating)
    /// - Parameter currentCount: Current number of templates
    /// - Parameter isPro: Whether user has Pro subscription
    /// - Returns: True if creation is allowed
    static func canCreate(currentCount: Int, isPro: Bool) -> Bool {
        isPro || currentCount < freeLimit
    }
}
