import Foundation
import SwiftData

/// A completed or in-progress workout session.
@Model
final class Workout {
    /// Unique identifier
    @Attribute(.unique) var id: UUID

    /// Workout title (auto-generated or custom)
    var title: String

    /// When the workout was started
    var startedAt: Date

    /// When the workout was finished (nil if in progress)
    var endedAt: Date?

    /// Optional workout notes
    var notes: String

    /// ID of the template used to start this workout (if any)
    var templateId: UUID?

    /// Exercises performed in this workout (ordered)
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise] = []

    // MARK: - Computed Properties

    /// Whether this workout is currently in progress
    var isInProgress: Bool {
        endedAt == nil
    }

    /// Duration of the workout (clamped to non-negative)
    var duration: TimeInterval {
        let endTime = endedAt ?? Date()
        return max(0, endTime.timeIntervalSince(startedAt))
    }

    /// Formatted duration string (e.g., "1h 45m")
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Live timer format for workout editor (HH:MM:SS)
    var liveDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Total number of completed sets
    var completedSetCount: Int {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.count
        }
    }

    /// All exercises in order
    var orderedExercises: [WorkoutExercise] {
        exercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    /// Total volume (weight × reps) for the entire workout
    var totalVolume: Double {
        orderedExercises.reduce(0) { $0 + $1.totalVolume }
    }

    /// Best set in the workout by e1RM (returns the WorkoutExercise and SetEntry)
    var topSet: (workoutExercise: WorkoutExercise, set: SetEntry)? {
        var best: (WorkoutExercise, SetEntry)?
        var bestE1RM: Double = 0

        for we in orderedExercises {
            if let bestSetInExercise = we.bestSet,
               let e1rm = bestSetInExercise.estimated1RM,
               e1rm > bestE1RM {
                bestE1RM = e1rm
                best = (we, bestSetInExercise)
            }
        }

        return best
    }

    /// Check if workout was modified from its original template
    /// Compares the workout's exercises to the template's exercise list
    func wasModifiedFromTemplate(_ template: Template?) -> Bool {
        guard let template = template, templateId == template.id else {
            return false
        }

        // Get exercise IDs from workout
        let workoutExerciseIds = orderedExercises.map { $0.exerciseId }

        // Compare to template's exercise IDs
        return workoutExerciseIds != template.orderedExerciseIds
    }

    // MARK: - Static Formatters (cached for performance)

    private static let titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE Workout"  // e.g., "Monday Workout"
        return formatter
    }()

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        title: String = "",
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        notes: String = "",
        templateId: UUID? = nil
    ) {
        self.id = id
        self.title = title.isEmpty ? Self.generateTitle(for: startedAt) : title
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.notes = notes
        self.templateId = templateId
    }

    // MARK: - Helpers

    /// Generate a default title based on the workout date
    static func generateTitle(for date: Date) -> String {
        titleFormatter.string(from: date)
    }

    /// Finish the workout
    func finish() {
        endedAt = Date()
    }

    /// Add an exercise to this workout
    func addExercise(_ exercise: WorkoutExercise) {
        exercise.orderIndex = exercises.count
        exercises.append(exercise)
    }

    /// Reindex all exercises to ensure contiguous ordering (call after deletions/reorders)
    func reindexExercises() {
        for (index, exercise) in orderedExercises.enumerated() {
            exercise.orderIndex = index
        }
    }
}
