import Foundation
import SwiftData

/// A single set performed within a workout exercise.
@Model
final class SetEntry {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Order within the exercise (0-based)
    var orderIndex: Int

    /// Weight used (stored in kg, converted for display)
    var weight: Double?

    /// Number of reps performed
    var reps: Int?

    /// Whether this set has been completed
    var isCompleted: Bool

    /// Rate of Perceived Exertion (1-10 scale, optional)
    var rpe: Double?

    /// Set type (warmup, working, dropset, failure)
    var setTypeRaw: String?

    /// Timestamp when this set was created/completed
    var createdAt: Date

    /// Parent workout exercise (inverse of WorkoutExercise.sets)
    var workoutExercise: WorkoutExercise?

    // MARK: - Computed Properties

    var setType: SetType? {
        get {
            guard let raw = setTypeRaw else { return nil }
            return SetType(rawValue: raw)
        }
        set { setTypeRaw = newValue?.rawValue }
    }

    /// Calculate estimated 1RM using Epley formula
    /// e1RM = weight × (1 + reps/30)
    var estimated1RM: Double? {
        guard let weight = weight, let reps = reps, reps > 0 else { return nil }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }

    /// Volume for this set (weight × reps)
    var volume: Double? {
        guard let weight = weight, let reps = reps else { return nil }
        return weight * Double(reps)
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        orderIndex: Int = 0,
        weight: Double? = nil,
        reps: Int? = nil,
        isCompleted: Bool = false,
        rpe: Double? = nil,
        setType: SetType? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.rpe = rpe
        self.setTypeRaw = setType?.rawValue
        self.createdAt = createdAt
    }

    // MARK: - Helpers

    /// Mark this set as completed
    func complete() {
        isCompleted = true
    }

    /// Toggle completion status
    func toggleComplete() {
        isCompleted.toggle()
    }

    /// Set RPE with validation (clamped to 1-10 range)
    func setRPE(_ value: Double?) {
        guard let value = value else {
            rpe = nil
            return
        }
        rpe = min(max(value, 1), 10)
    }

    /// Whether the current RPE value is valid (1-10)
    var isValidRPE: Bool {
        guard let rpe = rpe else { return true }  // nil is valid (not set)
        return rpe >= 1 && rpe <= 10
    }

    /// Formatted weight string based on unit preference
    func formattedWeight(unit: WeightUnit) -> String {
        guard let weight = weight else { return "—" }
        return weight.formatWeight(unit: unit, decimals: 1)
    }

    /// Formatted reps string
    var formattedReps: String {
        guard let reps = reps else { return "—" }
        return "\(reps)"
    }

    /// Summary string (e.g., "80kg × 8")
    func summary(unit: WeightUnit) -> String {
        guard let weight = weight, let reps = reps else { return "—" }
        let weightStr = weight.formatWeight(unit: unit, decimals: 1)
        return "\(weightStr) × \(reps)"
    }
}
