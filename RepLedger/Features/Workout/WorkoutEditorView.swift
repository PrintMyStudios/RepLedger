import SwiftUI
import SwiftData

/// Main workout editor screen for logging an active workout.
/// Redesigned with centered header, floating add button, and visual exercise cards.
struct WorkoutEditorView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.workoutManager) private var workoutManager

    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    @Query(filter: #Predicate<Workout> { $0.endedAt != nil }, sort: \Workout.startedAt, order: .reverse)
    private var completedWorkouts: [Workout]

    @State private var showExercisePicker = false
    @State private var showDiscardAlert = false
    @State private var previousPerformanceCache: [UUID: PreviousPerformance] = [:]
    @State private var draggingExerciseId: UUID?

    /// Derives workout from workoutManager to ensure consistency
    private var workout: Workout? {
        workoutManager.currentWorkout
    }

    var body: some View {
        let theme = themeManager.current

        Group {
            if let workout = workout {
                workoutContent(workout: workout, theme: theme)
            } else {
                noWorkoutView(theme: theme)
            }
        }
        .onAppear {
            // Ensure workoutManager has modelContext configured
            workoutManager.configure(modelContext: modelContext)
            loadPreviousPerformance()
        }
    }

    // MARK: - Main Content

    private func workoutContent(workout: Workout, theme: any Theme) -> some View {
        RestTimerOverlay {
            ZStack(alignment: .bottom) {
                scrollableContent(workout: workout, theme: theme)

                if !workout.orderedExercises.isEmpty {
                    floatingAddButton(theme: theme)
                }
            }
        }
        .safeAreaInset(edge: .top) {
            WorkoutHeaderView(
                workout: workout,
                onClose: { showDiscardAlert = true },
                onFinish: { finishWorkout() }
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView { exercise in
                addExercise(exercise)
            }
        }
        .alert("Discard Workout?", isPresented: $showDiscardAlert) {
            Button("Keep Logging", role: .cancel) { }
            Button("Discard", role: .destructive) {
                discardWorkout()
            }
        } message: {
            Text("Are you sure you want to discard this workout? All logged sets will be lost.")
        }
    }

    // MARK: - Scrollable Content

    private func scrollableContent(workout: Workout, theme: any Theme) -> some View {
        ScrollView {
            VStack(spacing: theme.spacing.md) {
                if workout.orderedExercises.isEmpty {
                    emptyState(theme: theme)
                } else {
                    exerciseList(workout: workout, theme: theme)
                }
            }
            .padding(.top, theme.spacing.md)
            .padding(.bottom, 120)
        }
        .background(theme.colors.background)
    }

    private func exerciseList(workout: Workout, theme: any Theme) -> some View {
        LazyVStack(spacing: theme.spacing.md) {
            ForEach(Array(workout.orderedExercises.enumerated()), id: \.element.id) { index, workoutExercise in
                exerciseCardWithDrag(
                    workoutExercise: workoutExercise,
                    index: index,
                    workout: workout,
                    theme: theme
                )
            }
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private func exerciseCardWithDrag(
        workoutExercise: WorkoutExercise,
        index: Int,
        workout: Workout,
        theme: any Theme
    ) -> some View {
        if let exercise = exerciseFor(id: workoutExercise.exerciseId) {
            ExerciseCardView(
                workoutExercise: workoutExercise,
                exercise: exercise,
                previousPerformance: previousPerformance(for: workoutExercise.exerciseId),
                onRemove: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        removeExercise(workoutExercise, from: workout)
                    }
                }
            )
            .opacity(draggingExerciseId == workoutExercise.id ? 0.5 : 1.0)
            .draggable(workoutExercise.id.uuidString) {
                exerciseDragPreview(exercise: exercise, theme: theme)
            }
            .dropDestination(for: String.self) { items, _ in
                handleDrop(items: items, destinationIndex: index, workout: workout)
            } isTargeted: { _ in }
            .onDrag {
                draggingExerciseId = workoutExercise.id
                return NSItemProvider(object: workoutExercise.id.uuidString as NSString)
            }
        }
    }

    private func handleDrop(items: [String], destinationIndex: Int, workout: Workout) -> Bool {
        guard let draggedIdString = items.first,
              let draggedId = UUID(uuidString: draggedIdString),
              let sourceIndex = workout.orderedExercises.firstIndex(where: { $0.id == draggedId }) else {
            return false
        }

        if sourceIndex != destinationIndex {
            withAnimation(.easeInOut(duration: 0.2)) {
                workoutManager.reorderExercises(
                    from: IndexSet(integer: sourceIndex),
                    to: destinationIndex > sourceIndex ? destinationIndex + 1 : destinationIndex
                )
            }
        }
        draggingExerciseId = nil
        return true
    }

    private func noWorkoutView(theme: any Theme) -> some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(theme.colors.warning)

            Text("No Active Workout")
                .font(theme.typography.titleSmall)
                .foregroundStyle(theme.colors.text)

            Text("Something went wrong. Please go back and start a new workout.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
        .navigationBarBackButtonHidden(false)
    }

    // MARK: - Floating Add Exercise Button

    private func floatingAddButton(theme: any Theme) -> some View {
        VStack(spacing: 0) {
            // Gradient fade
            LinearGradient(
                colors: [
                    theme.colors.background.opacity(0),
                    theme.colors.background.opacity(0.9),
                    theme.colors.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 32)

            // Button container
            Button {
                showExercisePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))

                    Text("Add Exercise")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundStyle(theme.colors.textOnAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(theme.colors.accent)
                .clipShape(Capsule())
                .shadow(color: theme.colors.accent.opacity(0.3), radius: 20, x: 0, y: 4)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.bottom, theme.spacing.sm)
            .background(theme.colors.background)
        }
    }

    // MARK: - Empty State

    private func emptyState(theme: any Theme) -> some View {
        VStack(spacing: theme.spacing.md) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.colors.textTertiary)

            Text("No Exercises Yet")
                .font(theme.typography.titleSmall)
                .foregroundStyle(theme.colors.text)

            Text("Add your first exercise to start logging")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)

            Text("Tip: Use Templates to pre-load your routine")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .padding(.top, theme.spacing.xs)

            Button {
                showExercisePicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))

                    Text("Add Exercise")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(theme.colors.textOnAccent)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(theme.colors.accent)
                .clipShape(Capsule())
                .shadow(color: theme.colors.accent.opacity(0.3), radius: 15, x: 0, y: 4)
            }
            .padding(.top, theme.spacing.md)
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Drag Preview

    private func exerciseDragPreview(exercise: Exercise, theme: any Theme) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.colors.textTertiary)

            Text(exercise.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.colors.text)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(theme.colors.accent.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    // MARK: - Helpers

    private func exerciseFor(id: UUID) -> Exercise? {
        allExercises.first { $0.id == id }
    }

    private func previousPerformance(for exerciseId: UUID) -> PreviousPerformance? {
        previousPerformanceCache[exerciseId]
    }

    private func loadPreviousPerformance() {
        guard let workout = workout else { return }

        for workoutExercise in workout.orderedExercises {
            let exerciseId = workoutExercise.exerciseId

            let previousWorkout = completedWorkouts.first { w in
                w.id != workout.id &&
                w.exercises.contains { $0.exerciseId == exerciseId }
            }

            if let previousWorkout = previousWorkout,
               let previousExercise = previousWorkout.exercises.first(where: { $0.exerciseId == exerciseId }) {
                previousPerformanceCache[exerciseId] = PreviousPerformance.from(
                    previousExercise,
                    workoutDate: previousWorkout.startedAt
                )
            }
        }
    }

    private func addExercise(_ exercise: Exercise) {
        // Ensure workoutManager has modelContext configured
        workoutManager.configure(modelContext: modelContext)
        workoutManager.addExercise(exercise)

        guard let workout = workout else { return }

        let exerciseId = exercise.id
        let previousWorkout = completedWorkouts.first { w in
            w.id != workout.id &&
            w.exercises.contains { $0.exerciseId == exerciseId }
        }

        if let previousWorkout = previousWorkout,
           let previousExercise = previousWorkout.exercises.first(where: { $0.exerciseId == exerciseId }) {
            previousPerformanceCache[exerciseId] = PreviousPerformance.from(
                previousExercise,
                workoutDate: previousWorkout.startedAt
            )
        }
    }

    private func removeExercise(_ workoutExercise: WorkoutExercise, from workout: Workout) {
        if let index = workout.orderedExercises.firstIndex(where: { $0.id == workoutExercise.id }) {
            workoutManager.removeExercise(at: index)
        }
    }

    private func finishWorkout() {
        workoutManager.finishWorkout()
        dismiss()
    }

    private func discardWorkout() {
        workoutManager.discardWorkout()
        dismiss()
    }
}

// MARK: - Preview

#Preview("WorkoutEditorView") {
    let workoutManager = WorkoutManager()

    NavigationStack {
        Text("Preview requires active workout")
    }
    .environment(ThemeManager())
    .environment(\.workoutManager, workoutManager)
}
