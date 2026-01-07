import Foundation
import SwiftUI
import SwiftData
import Combine

/// Manages active workout state and rest timer.
@Observable
@MainActor
final class WorkoutManager {
    // MARK: - Properties

    /// Current active workout (nil if no workout in progress)
    private(set) var currentWorkout: Workout?

    /// Rest timer state
    private(set) var restTimer: RestTimerState?

    /// Model context for persistence
    private var modelContext: ModelContext?

    /// Timer cancellable
    private var timerCancellable: AnyCancellable?

    // MARK: - Computed Properties

    /// Whether there's an active workout
    var hasActiveWorkout: Bool {
        currentWorkout != nil
    }

    /// Whether the rest timer is running
    var isTimerRunning: Bool {
        restTimer?.isRunning ?? false
    }

    /// Whether the rest timer is active (running or paused)
    var isTimerActive: Bool {
        restTimer != nil
    }

    // MARK: - Initialization

    nonisolated init() {}

    /// Configure with model context (call on app launch)
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        resumeActiveWorkoutIfNeeded()
    }

    // MARK: - Workout Lifecycle

    /// Start an empty workout (Quick Start)
    @discardableResult
    func startEmptyWorkout() -> Workout {
        let workout = Workout()
        modelContext?.insert(workout)
        currentWorkout = workout
        saveActiveWorkoutId()
        return workout
    }

    /// Start a workout from a template
    @discardableResult
    func startFromTemplate(_ template: Template, exercises: [Exercise]) -> Workout {
        let workout = Workout(templateId: template.id)
        modelContext?.insert(workout)

        // Add exercises from template
        for exerciseId in template.orderedExerciseIds {
            let workoutExercise = WorkoutExercise(exerciseId: exerciseId)
            workout.addExercise(workoutExercise)

            // Add one empty set per exercise
            let set = SetEntry()
            workoutExercise.addSet(set)
        }

        // Update template's lastUsedAt
        template.lastUsedAt = Date()

        currentWorkout = workout
        saveActiveWorkoutId()
        return workout
    }

    /// Start a workout by repeating a previous workout's structure
    /// Clones exercise order, set count, and set types (warmup/working/etc.)
    /// Weight and reps start empty, completion state cleared
    @discardableResult
    func startFromWorkout(_ sourceWorkout: Workout) -> Workout {
        let newWorkout = Workout()

        // Copy template reference if original was from template
        if let templateId = sourceWorkout.templateId {
            newWorkout.templateId = templateId
        }

        modelContext?.insert(newWorkout)

        // Clone each exercise with FULL set structure
        for (exerciseIndex, sourceExercise) in sourceWorkout.orderedExercises.enumerated() {
            let newExercise = WorkoutExercise(exerciseId: sourceExercise.exerciseId)
            newExercise.orderIndex = exerciseIndex
            newWorkout.addExercise(newExercise)

            // Clone ALL sets, preserving setType, but clearing weight/reps/completion
            for (setIndex, sourceSet) in sourceExercise.orderedSets.enumerated() {
                let newSet = SetEntry()
                newSet.orderIndex = setIndex
                newSet.setType = sourceSet.setType  // Preserve warmup/working/dropset/failure
                newSet.weight = nil  // Start empty
                newSet.reps = nil    // Start empty
                newSet.isCompleted = false
                newExercise.addSet(newSet)
            }
        }

        // Set as active workout (triggers navigation via state change)
        currentWorkout = newWorkout
        saveActiveWorkoutId()
        saveContext()

        return newWorkout
    }

    /// Finish the current workout
    func finishWorkout() {
        guard let workout = currentWorkout else { return }

        // Guard: only increment if transitioning from active to completed
        // AND workout has at least one completed set (avoid counting empty sessions)
        let wasInProgress = workout.isInProgress
        let hasCompletedSets = workout.orderedExercises.contains { exercise in
            exercise.orderedSets.contains { $0.isCompleted }
        }

        workout.finish()
        saveContext()
        clearActiveWorkoutId()
        currentWorkout = nil
        dismissTimer()

        // Increment only on genuine workout completion
        if wasInProgress && hasCompletedSets {
            UserSettings.shared.completedWorkoutCount += 1
        }
    }

    /// Discard the current workout without saving
    func discardWorkout() {
        guard let workout = currentWorkout else { return }
        modelContext?.delete(workout)
        saveContext()
        clearActiveWorkoutId()
        currentWorkout = nil
        dismissTimer()
    }

    /// Resume an in-progress workout (called on app launch)
    private func resumeActiveWorkoutIfNeeded() {
        guard let workoutIdString = UserDefaults.standard.string(forKey: "activeWorkoutId"),
              let workoutId = UUID(uuidString: workoutIdString),
              let modelContext = modelContext else { return }

        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.id == workoutId }
        )

        do {
            let workouts = try modelContext.fetch(descriptor)
            if let workout = workouts.first, workout.isInProgress {
                currentWorkout = workout
            } else {
                // Workout was finished or deleted, clear the stored ID
                clearActiveWorkoutId()
            }
        } catch {
            print("Error resuming workout: \(error)")
            clearActiveWorkoutId()
        }
    }

    // MARK: - Exercise Management

    /// Add an exercise to the current workout
    func addExercise(_ exercise: Exercise) {
        guard let workout = currentWorkout else { return }

        let workoutExercise = WorkoutExercise(exerciseId: exercise.id)
        workout.addExercise(workoutExercise)

        // Add one empty set
        let set = SetEntry()
        workoutExercise.addSet(set)

        saveContext()
    }

    /// Remove an exercise from the current workout
    func removeExercise(at index: Int) {
        guard let workout = currentWorkout,
              index < workout.orderedExercises.count else { return }

        let exercise = workout.orderedExercises[index]
        modelContext?.delete(exercise)

        // Build remaining exercises array and reindex from 0
        let remaining = workout.orderedExercises.filter { $0.id != exercise.id }
        for (newIndex, ex) in remaining.enumerated() {
            ex.orderIndex = newIndex
        }

        saveContext()
    }

    /// Reorder exercises in the current workout
    func reorderExercises(from source: IndexSet, to destination: Int) {
        guard let workout = currentWorkout else { return }

        var exercises = workout.orderedExercises
        exercises.move(fromOffsets: source, toOffset: destination)

        for (index, exercise) in exercises.enumerated() {
            exercise.orderIndex = index
        }

        saveContext()
    }

    /// Update the workout title
    func updateWorkoutTitle(_ newTitle: String) {
        guard let workout = currentWorkout else { return }
        workout.title = newTitle.isEmpty ? Workout.generateTitle(for: workout.startedAt) : newTitle
        saveContext()
    }

    // MARK: - Set Management

    /// Add a new set to an exercise
    func addSet(to workoutExercise: WorkoutExercise) {
        let set = SetEntry()
        workoutExercise.addSet(set)
        saveContext()
    }

    /// Duplicate the last set of an exercise
    @discardableResult
    func duplicateLastSet(for workoutExercise: WorkoutExercise) -> SetEntry? {
        let newSet = workoutExercise.duplicateLastSet()
        saveContext()
        return newSet
    }

    /// Delete a set from an exercise
    func deleteSet(_ set: SetEntry, from workoutExercise: WorkoutExercise) {
        modelContext?.delete(set)

        // Build remaining sets array and reindex from 0
        let remaining = workoutExercise.orderedSets.filter { $0.id != set.id }
        for (newIndex, s) in remaining.enumerated() {
            s.orderIndex = newIndex
        }

        saveContext()
    }

    /// Complete a set (and optionally start rest timer)
    func completeSet(_ set: SetEntry, autoStartTimer: Bool = false, timerDuration: Int = 90) {
        let wasCompleted = set.isCompleted
        set.toggleComplete()
        saveContext()

        // Start timer if completing (not uncompleting) and auto-start is enabled
        if !wasCompleted && set.isCompleted && autoStartTimer {
            startTimer(duration: timerDuration)
        }
    }

    // MARK: - Rest Timer

    /// Start the rest timer
    func startTimer(duration: Int, context: String? = nil) {
        // Cancel any existing timer
        timerCancellable?.cancel()

        restTimer = RestTimerState(
            totalDuration: duration,
            remainingTime: duration,
            isRunning: true,
            exerciseContext: context
        )

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerTick()
            }
    }

    /// Pause the rest timer
    func pauseTimer() {
        restTimer?.isRunning = false
        timerCancellable?.cancel()
    }

    /// Resume the rest timer
    func resumeTimer() {
        guard restTimer != nil, restTimer?.isRunning == false else { return }

        // Cancel any existing timer first to prevent double timers
        timerCancellable?.cancel()

        restTimer?.isRunning = true

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerTick()
            }
    }

    /// Add time to the rest timer
    func addTime(_ seconds: Int) {
        guard restTimer != nil else { return }
        restTimer?.remainingTime += seconds
        restTimer?.totalDuration += seconds
    }

    /// Dismiss the rest timer
    func dismissTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        restTimer = nil
    }

    private func timerTick() {
        guard var timer = restTimer, timer.isRunning else { return }

        if timer.remainingTime > 0 {
            timer.remainingTime -= 1
            restTimer = timer
        } else {
            // Timer completed
            timerCancellable?.cancel()
            timer.isRunning = false
            restTimer = timer
            // Timer stays visible showing 0:00 until dismissed
        }
    }

    // MARK: - Persistence Helpers

    private func saveContext() {
        try? modelContext?.save()
    }

    private func saveActiveWorkoutId() {
        guard let workout = currentWorkout else { return }
        UserDefaults.standard.set(workout.id.uuidString, forKey: "activeWorkoutId")
    }

    private func clearActiveWorkoutId() {
        UserDefaults.standard.removeObject(forKey: "activeWorkoutId")
    }
}

// MARK: - Rest Timer State

struct RestTimerState {
    var totalDuration: Int
    var remainingTime: Int
    var isRunning: Bool
    var exerciseContext: String?

    var formattedTime: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(totalDuration - remainingTime) / Double(totalDuration)
    }

    var isComplete: Bool {
        remainingTime <= 0
    }
}

// MARK: - Environment Key

private struct WorkoutManagerKey: EnvironmentKey {
    static let defaultValue = WorkoutManager()
}

extension EnvironmentValues {
    var workoutManager: WorkoutManager {
        get { self[WorkoutManagerKey.self] }
        set { self[WorkoutManagerKey.self] = newValue }
    }
}
