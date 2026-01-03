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
    var exercises: [WorkoutExercise]?

    // MARK: - Computed Properties

    /// Whether this workout is currently in progress
    var isInProgress: Bool {
        endedAt == nil
    }

    /// Duration of the workout
    var duration: TimeInterval? {
        guard let endedAt = endedAt else {
            return Date().timeIntervalSince(startedAt)
        }
        return endedAt.timeIntervalSince(startedAt)
    }

    /// Formatted duration string
    var formattedDuration: String {
        guard let duration = duration else { return "—" }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Total number of completed sets
    var completedSetCount: Int {
        exercises?.reduce(0) { total, exercise in
            total + (exercise.sets?.filter { $0.isCompleted }.count ?? 0)
        } ?? 0
    }

    /// All exercises in order
    var orderedExercises: [WorkoutExercise] {
        exercises?.sorted { $0.orderIndex < $1.orderIndex } ?? []
    }

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
        self.exercises = []
    }

    // MARK: - Helpers

    /// Generate a default title based on the workout date
    static func generateTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE Workout"  // e.g., "Monday Workout"
        return formatter.string(from: date)
    }

    /// Finish the workout
    func finish() {
        endedAt = Date()
    }

    /// Add an exercise to this workout
    func addExercise(_ exercise: WorkoutExercise) {
        if exercises == nil {
            exercises = []
        }
        exercise.orderIndex = exercises!.count
        exercises!.append(exercise)
    }
}
