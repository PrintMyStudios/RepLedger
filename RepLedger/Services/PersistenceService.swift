import Foundation
import SwiftData

/// Service for managing data persistence and seeding.
@MainActor
final class PersistenceService {
    private let modelContext: ModelContext

    private static let hasSeededExercisesKey = "hasSeededExercises"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Exercise Seeding

    /// Seeds the exercise library on first launch
    func seedExercisesIfNeeded() {
        // Use UserDefaults to track if we've seeded (more reliable than counting)
        if UserDefaults.standard.bool(forKey: Self.hasSeededExercisesKey) {
            return
        }

        // Seed exercises
        let exercises = Self.createSeedExercises()
        for exercise in exercises {
            modelContext.insert(exercise)
        }

        do {
            try modelContext.save()
            UserDefaults.standard.set(true, forKey: Self.hasSeededExercisesKey)
            print("Seeded \(exercises.count) exercises")
        } catch {
            print("Error seeding exercises: \(error)")
        }
    }

    /// Creates the seed exercise list
    static func createSeedExercises() -> [Exercise] {
        var exercises: [Exercise] = []

        // MARK: - Chest Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell),
            Exercise.seeded(name: "Incline Barbell Press", muscleGroup: .chest, equipment: .barbell),
            Exercise.seeded(name: "Decline Barbell Press", muscleGroup: .chest, equipment: .barbell),
            Exercise.seeded(name: "Dumbbell Bench Press", muscleGroup: .chest, equipment: .dumbbell),
            Exercise.seeded(name: "Incline Dumbbell Press", muscleGroup: .chest, equipment: .dumbbell),
            Exercise.seeded(name: "Dumbbell Fly", muscleGroup: .chest, equipment: .dumbbell),
            Exercise.seeded(name: "Cable Crossover", muscleGroup: .chest, equipment: .cable),
            Exercise.seeded(name: "Push-Up", muscleGroup: .chest, equipment: .bodyweight),
            Exercise.seeded(name: "Chest Dip", muscleGroup: .chest, equipment: .bodyweight),
            Exercise.seeded(name: "Machine Chest Press", muscleGroup: .chest, equipment: .machine),
        ])

        // MARK: - Back Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Barbell Row", muscleGroup: .back, equipment: .barbell),
            Exercise.seeded(name: "Deadlift", muscleGroup: .back, equipment: .barbell),
            Exercise.seeded(name: "Pull-Up", muscleGroup: .back, equipment: .bodyweight),
            Exercise.seeded(name: "Chin-Up", muscleGroup: .back, equipment: .bodyweight),
            Exercise.seeded(name: "Lat Pulldown", muscleGroup: .back, equipment: .cable),
            Exercise.seeded(name: "Seated Cable Row", muscleGroup: .back, equipment: .cable),
            Exercise.seeded(name: "Single-Arm Dumbbell Row", muscleGroup: .back, equipment: .dumbbell),
            Exercise.seeded(name: "T-Bar Row", muscleGroup: .back, equipment: .barbell),
            Exercise.seeded(name: "Face Pull", muscleGroup: .back, equipment: .cable),
            Exercise.seeded(name: "Straight-Arm Pulldown", muscleGroup: .back, equipment: .cable),
        ])

        // MARK: - Shoulder Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Overhead Press", muscleGroup: .shoulders, equipment: .barbell),
            Exercise.seeded(name: "Seated Dumbbell Press", muscleGroup: .shoulders, equipment: .dumbbell),
            Exercise.seeded(name: "Arnold Press", muscleGroup: .shoulders, equipment: .dumbbell),
            Exercise.seeded(name: "Lateral Raise", muscleGroup: .shoulders, equipment: .dumbbell),
            Exercise.seeded(name: "Front Raise", muscleGroup: .shoulders, equipment: .dumbbell),
            Exercise.seeded(name: "Rear Delt Fly", muscleGroup: .shoulders, equipment: .dumbbell),
            Exercise.seeded(name: "Upright Row", muscleGroup: .shoulders, equipment: .barbell),
            Exercise.seeded(name: "Cable Lateral Raise", muscleGroup: .shoulders, equipment: .cable),
        ])

        // MARK: - Biceps Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Barbell Curl", muscleGroup: .biceps, equipment: .barbell),
            Exercise.seeded(name: "Dumbbell Curl", muscleGroup: .biceps, equipment: .dumbbell),
            Exercise.seeded(name: "Hammer Curl", muscleGroup: .biceps, equipment: .dumbbell),
            Exercise.seeded(name: "Preacher Curl", muscleGroup: .biceps, equipment: .barbell),
            Exercise.seeded(name: "Incline Dumbbell Curl", muscleGroup: .biceps, equipment: .dumbbell),
            Exercise.seeded(name: "Cable Curl", muscleGroup: .biceps, equipment: .cable),
        ])

        // MARK: - Triceps Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Close-Grip Bench Press", muscleGroup: .triceps, equipment: .barbell),
            Exercise.seeded(name: "Tricep Pushdown", muscleGroup: .triceps, equipment: .cable),
            Exercise.seeded(name: "Skull Crusher", muscleGroup: .triceps, equipment: .barbell),
            Exercise.seeded(name: "Overhead Tricep Extension", muscleGroup: .triceps, equipment: .dumbbell),
            Exercise.seeded(name: "Tricep Dip", muscleGroup: .triceps, equipment: .bodyweight),
            Exercise.seeded(name: "Diamond Push-Up", muscleGroup: .triceps, equipment: .bodyweight),
        ])

        // MARK: - Quadriceps Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Back Squat", muscleGroup: .quadriceps, equipment: .barbell),
            Exercise.seeded(name: "Front Squat", muscleGroup: .quadriceps, equipment: .barbell),
            Exercise.seeded(name: "Leg Press", muscleGroup: .quadriceps, equipment: .machine),
            Exercise.seeded(name: "Leg Extension", muscleGroup: .quadriceps, equipment: .machine),
            Exercise.seeded(name: "Walking Lunge", muscleGroup: .quadriceps, equipment: .dumbbell),
            Exercise.seeded(name: "Bulgarian Split Squat", muscleGroup: .quadriceps, equipment: .dumbbell),
            Exercise.seeded(name: "Goblet Squat", muscleGroup: .quadriceps, equipment: .kettlebell),
        ])

        // MARK: - Hamstrings Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Romanian Deadlift", muscleGroup: .hamstrings, equipment: .barbell),
            Exercise.seeded(name: "Lying Leg Curl", muscleGroup: .hamstrings, equipment: .machine),
            Exercise.seeded(name: "Seated Leg Curl", muscleGroup: .hamstrings, equipment: .machine),
            Exercise.seeded(name: "Good Morning", muscleGroup: .hamstrings, equipment: .barbell),
            Exercise.seeded(name: "Nordic Curl", muscleGroup: .hamstrings, equipment: .bodyweight),
        ])

        // MARK: - Glutes Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Hip Thrust", muscleGroup: .glutes, equipment: .barbell),
            Exercise.seeded(name: "Glute Bridge", muscleGroup: .glutes, equipment: .bodyweight),
            Exercise.seeded(name: "Cable Kickback", muscleGroup: .glutes, equipment: .cable),
            Exercise.seeded(name: "Sumo Deadlift", muscleGroup: .glutes, equipment: .barbell),
        ])

        // MARK: - Calves Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Standing Calf Raise", muscleGroup: .calves, equipment: .machine),
            Exercise.seeded(name: "Seated Calf Raise", muscleGroup: .calves, equipment: .machine),
            Exercise.seeded(name: "Donkey Calf Raise", muscleGroup: .calves, equipment: .machine),
        ])

        // MARK: - Core Exercises
        exercises.append(contentsOf: [
            Exercise.seeded(name: "Plank", muscleGroup: .core, equipment: .bodyweight),
            Exercise.seeded(name: "Hanging Leg Raise", muscleGroup: .core, equipment: .bodyweight),
            Exercise.seeded(name: "Cable Crunch", muscleGroup: .core, equipment: .cable),
            Exercise.seeded(name: "Ab Wheel Rollout", muscleGroup: .core, equipment: .other),
            Exercise.seeded(name: "Russian Twist", muscleGroup: .core, equipment: .bodyweight),
            Exercise.seeded(name: "Dead Bug", muscleGroup: .core, equipment: .bodyweight),
        ])

        return exercises
    }

    // MARK: - Fetch Helpers

    /// Fetch all exercises
    func fetchAllExercises() throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch exercises by muscle group
    func fetchExercises(muscleGroup: MuscleGroup) throws -> [Exercise] {
        let muscleGroupRaw = muscleGroup.rawValue
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.muscleGroupRaw == muscleGroupRaw },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Search exercises by name
    func searchExercises(query: String) throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.name.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch all templates
    func fetchAllTemplates() throws -> [Template] {
        let descriptor = FetchDescriptor<Template>(
            sortBy: [SortDescriptor(\.lastUsedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Count templates for gating check
    func countTemplates() throws -> Int {
        let descriptor = FetchDescriptor<Template>()
        return try modelContext.fetchCount(descriptor)
    }

    /// Fetch all workouts
    func fetchAllWorkouts() throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetch workouts for a specific exercise
    func fetchWorkouts(containing exerciseId: UUID) throws -> [Workout] {
        // Note: This is a basic implementation; may need optimization for large datasets
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        let workouts = try modelContext.fetch(descriptor)
        return workouts.filter { workout in
            workout.exercises.contains { $0.exerciseId == exerciseId }
        }
    }

    // MARK: - Template Creation

    /// Create a new template from a completed workout's exercises
    /// - Parameters:
    ///   - workout: The workout to extract exercises from
    ///   - name: The name for the new template
    /// - Returns: The created template
    /// - Throws: If save fails
    func createTemplateFromWorkout(_ workout: Workout, name: String) throws -> Template {
        let exerciseIds = workout.orderedExercises.map { $0.exerciseId }
        let template = Template(name: name, orderedExerciseIds: exerciseIds)
        modelContext.insert(template)
        try modelContext.save()
        return template
    }

    // MARK: - Delete Helpers

    /// Delete a workout and all its related data.
    /// NOTE: SwiftData relationships are configured with .cascade deleteRule:
    ///   - Workout → WorkoutExercise (cascade)
    ///   - WorkoutExercise → SetEntry (cascade)
    /// If cascade ever fails, explicitly delete children first.
    func deleteWorkout(_ workout: Workout) throws {
        modelContext.delete(workout)
        try modelContext.save()
    }
}
