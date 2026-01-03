import Foundation
import SwiftData

/// An exercise in the library (seeded or custom).
@Model
final class Exercise {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Exercise name (e.g., "Barbell Bench Press")
    var name: String

    /// Primary muscle group targeted
    var muscleGroupRaw: String

    /// Equipment required
    var equipmentRaw: String

    /// Optional notes or description
    var notes: String

    /// Whether this is a user-created exercise
    var isCustom: Bool

    /// Creation timestamp
    var createdAt: Date

    // MARK: - Computed Properties

    var muscleGroup: MuscleGroup {
        get { MuscleGroup(rawValue: muscleGroupRaw) ?? .fullBody }
        set { muscleGroupRaw = newValue.rawValue }
    }

    var equipment: Equipment {
        get { Equipment(rawValue: equipmentRaw) ?? .other }
        set { equipmentRaw = newValue.rawValue }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        equipment: Equipment,
        notes: String = "",
        isCustom: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.muscleGroupRaw = muscleGroup.rawValue
        self.equipmentRaw = equipment.rawValue
        self.notes = notes
        self.isCustom = isCustom
        self.createdAt = createdAt
    }
}

// MARK: - Convenience

extension Exercise {
    /// Creates a seeded exercise (not custom)
    static func seeded(
        name: String,
        muscleGroup: MuscleGroup,
        equipment: Equipment,
        notes: String = ""
    ) -> Exercise {
        Exercise(
            name: name,
            muscleGroup: muscleGroup,
            equipment: equipment,
            notes: notes,
            isCustom: false
        )
    }
}
