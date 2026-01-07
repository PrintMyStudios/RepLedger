import SwiftUI
import SwiftData

/// Redesigned workout detail view with premium UI
/// Shows stats summary, PR highlights, expandable exercise cards, and bottom actions
struct WorkoutDetailView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.userSettings) private var settings
    @Environment(\.workoutManager) private var workoutManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var allExercises: [Exercise]

    let workout: Workout

    // MARK: - State

    @State private var metricsActor: MetricsActor?
    @State private var prResults: [WorkoutSetPR] = []
    @State private var expandedExercises: Set<UUID> = []
    @State private var showDeleteAlert = false
    @State private var showDeleteError = false
    @State private var showTemplateSheet = false
    @State private var isNotesHighlighted = false

    var body: some View {
        let theme = themeManager.current

        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(spacing: theme.spacing.md) {
                    // Header
                    WorkoutDetailHeader(
                        title: workout.title,
                        date: workout.startedAt,
                        duration: workout.duration,
                        onRepeat: repeatWorkout,
                        onSaveAsTemplate: { showTemplateSheet = true },
                        onDelete: { showDeleteAlert = true }
                    )

                    // Stats card
                    WorkoutDetailStatsCard(
                        volume: totalVolume,
                        setCount: workout.completedSetCount,
                        prCount: prResults.count,
                        exerciseCount: workout.orderedExercises.count,
                        duration: workout.duration,
                        hasNotes: !workout.notes.isEmpty,
                        onNotesReadTap: {
                            withAnimation {
                                scrollProxy.scrollTo("notesCard", anchor: .top)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    isNotesHighlighted = true
                                }
                            }
                        }
                    )
                    .padding(.horizontal, theme.spacing.md)

                    // Notes card (if notes exist)
                    if !workout.notes.isEmpty {
                        WorkoutDetailNotesCard(
                            notes: workout.notes,
                            isHighlighted: $isNotesHighlighted
                        )
                        .id("notesCard")
                        .padding(.horizontal, theme.spacing.md)
                    }

                    // PR Highlights (if any PRs)
                    if !prResults.isEmpty {
                        PRHighlightsCard(prs: prResults)
                            .padding(.horizontal, theme.spacing.md)
                    }

                    // Exercises section
                    exercisesSection

                    // Bottom spacing for action bar
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.top, theme.spacing.sm)
            }
            .background(theme.colors.background)
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            bottomActionBar
        }
        .alert("Delete Workout?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteWorkout()
            }
        } message: {
            Text("This will permanently delete this workout and all its data.")
        }
        .alert("Delete Failed", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Unable to delete workout. Please try again.")
        }
        .sheet(isPresented: $showTemplateSheet) {
            TemplateNameSheet(workoutTitle: workout.title) { name in
                saveAsTemplate(name: name)
            }
        }
        .task(id: workout.id) {
            await loadData()
        }
    }

    // MARK: - Exercises Section

    private var exercisesSection: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.sm) {
            ForEach(workout.orderedExercises) { workoutExercise in
                if let exercise = exerciseFor(workoutExercise.exerciseId) {
                    WorkoutDetailExerciseCard(
                        workoutExercise: workoutExercise,
                        exercise: exercise,
                        prInfo: prsForExercise(workoutExercise.exerciseId),
                        isExpanded: expandedExercises.contains(workoutExercise.id),
                        onToggle: {
                            toggleExpanded(workoutExercise.id)
                        }
                    )
                    .padding(.horizontal, theme.spacing.md)
                } else {
                    // Fallback for deleted exercises
                    deletedExerciseCard(workoutExercise)
                        .padding(.horizontal, theme.spacing.md)
                }
            }
        }
    }

    private func deletedExerciseCard(_ workoutExercise: WorkoutExercise) -> some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(theme.colors.textTertiary)
                Text("Deleted Exercise")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.colors.textSecondary)
                    .italic()
                Spacer()
                Text("\(workoutExercise.orderedSets.filter { $0.isCompleted }.count) sets")
                    .font(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .stroke(theme.colors.border, lineWidth: 1)
        }
    }

    // MARK: - Bottom Action Bar

    private var bottomActionBar: some View {
        let theme = themeManager.current

        return HStack(spacing: theme.spacing.md) {
            // Use as Template button
            Button {
                showTemplateSheet = true
            } label: {
                Text("Use as Template")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.colors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            }

            // Repeat Workout button
            Button {
                repeatWorkout()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                    Text("Repeat Workout")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            }
            .rlShadow(theme.shadows.subtle)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.md)
        .background(
            theme.colors.background
                .opacity(0.95)
                .background(.ultraThinMaterial)
        )
    }

    // MARK: - Data Loading

    private func loadData() async {
        // Initialize metrics actor
        if metricsActor == nil {
            metricsActor = MetricsActor(modelContainer: modelContext.container)
        }

        // Build exercise name map
        let exerciseNameMap = Dictionary(
            uniqueKeysWithValues: allExercises.map { ($0.id, $0.name) }
        )

        // Load PRs
        if let actor = metricsActor {
            let results = await actor.getWorkoutPRDetails(
                workoutId: workout.id,
                exerciseNameMap: exerciseNameMap
            )
            await MainActor.run {
                prResults = results
            }
        }

        // Initialize expanded exercises (first 2)
        let firstTwoExercises = workout.orderedExercises.prefix(2).map { $0.id }
        await MainActor.run {
            expandedExercises = Set(firstTwoExercises)
        }
    }

    // MARK: - Helpers

    private var totalVolume: Double {
        workout.orderedExercises.reduce(0) { $0 + $1.totalVolume }
    }

    private func exerciseFor(_ id: UUID) -> Exercise? {
        allExercises.first { $0.id == id }
    }

    private func prsForExercise(_ exerciseId: UUID) -> [WorkoutSetPR] {
        prResults.filter { $0.exerciseId == exerciseId }
    }

    private func toggleExpanded(_ exerciseId: UUID) {
        if expandedExercises.contains(exerciseId) {
            expandedExercises.remove(exerciseId)
        } else {
            expandedExercises.insert(exerciseId)
        }
    }

    // MARK: - Actions

    private func repeatWorkout() {
        // Start new workout from this workout's structure
        workoutManager.startFromWorkout(workout)
        // Dismiss this view - ContentView will react to hasActiveWorkout
        dismiss()
    }

    private func saveAsTemplate(name: String) {
        let persistenceService = PersistenceService(modelContext: modelContext)
        do {
            _ = try persistenceService.createTemplateFromWorkout(workout, name: name)
            // Could show a success toast here
        } catch {
            // Could show an error toast here
            print("Error creating template: \(error)")
        }
    }

    private func deleteWorkout() {
        let persistenceService = PersistenceService(modelContext: modelContext)
        do {
            try persistenceService.deleteWorkout(workout)
            dismiss()
        } catch {
            showDeleteError = true
        }
    }
}

// MARK: - Preview

#Preview("WorkoutDetailView") {
    NavigationStack {
        WorkoutDetailView(
            workout: Workout(
                title: "Hypertrophy Push",
                startedAt: Date().addingTimeInterval(-4500),
                endedAt: Date()
            )
        )
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, SetEntry.self, Exercise.self])
    .environment(ThemeManager())
}
