import Foundation
import SwiftData

/// An exercise performed within a specific workout.
/// Links a Workout to an Exercise and contains the sets performed.
@Model
final class WorkoutExercise {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Reference to the exercise definition
    var exerciseId: UUID

    /// Order within the workout (0-based)
    var orderIndex: Int

    /// Optional notes for this exercise in this workout
    var notes: String

    /// Parent workout (inverse of Workout.exercises)
    var workout: Workout?

    /// Sets performed for this exercise
    @Relationship(deleteRule: .cascade, inverse: \SetEntry.workoutExercise)
    var sets: [SetEntry] = []

    // MARK: - Computed Properties

    /// All sets in order
    var orderedSets: [SetEntry] {
        sets.sorted { $0.orderIndex < $1.orderIndex }
    }

    /// Number of completed sets
    var completedSetCount: Int {
        sets.filter { $0.isCompleted }.count
    }

    /// Total volume (weight × reps) for this exercise
    var totalVolume: Double {
        orderedSets.reduce(0) { total, set in
            guard set.isCompleted,
                  let weight = set.weight,
                  let reps = set.reps else { return total }
            return total + (weight * Double(reps))
        }
    }

    /// Best set by estimated 1RM
    var bestSet: SetEntry? {
        orderedSets
            .filter { $0.isCompleted && $0.weight != nil && $0.reps != nil }
            .max { ($0.estimated1RM ?? 0) < ($1.estimated1RM ?? 0) }
    }

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        orderIndex: Int = 0,
        notes: String = ""
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.orderIndex = orderIndex
        self.notes = notes
    }

    // MARK: - Helpers

    /// Add a new set to this exercise
    func addSet(_ set: SetEntry) {
        set.orderIndex = sets.count
        sets.append(set)
    }

    /// Reindex all sets to ensure contiguous ordering (call after deletions/reorders)
    func reindexSets() {
        for (index, set) in orderedSets.enumerated() {
            set.orderIndex = index
        }
    }

    /// Duplicate the last set
    func duplicateLastSet() -> SetEntry? {
        guard let lastSet = orderedSets.last else { return nil }
        let newSet = SetEntry(
            weight: lastSet.weight,
            reps: lastSet.reps,
            setType: lastSet.setType
        )
        addSet(newSet)
        return newSet
    }
}
