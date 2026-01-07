import SwiftUI
import SwiftData

/// Detail view for an exercise with tabs: About, History, Records, Charts.
struct ExerciseDetailView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let exercise: Exercise

    @State private var selectedTab: Tab = .about
    @State private var metricsActor: MetricsActor?
    @State private var history: [ExerciseHistorySummary] = []
    @State private var personalRecords: [PRType: PersonalRecord] = [:]
    @State private var isLoading = true

    enum Tab: String, CaseIterable {
        case about = "About"
        case history = "History"
        case records = "Records"
        case charts = "Charts"
    }

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: 0) {
            // Tab picker
            Picker("Tab", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(theme.spacing.md)

            // Tab content
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch selectedTab {
                    case .about:
                        ExerciseAboutTab(exercise: exercise)
                    case .history:
                        ExerciseHistoryTab(exercise: exercise, history: history)
                    case .records:
                        ExerciseRecordsTab(exercise: exercise, personalRecords: personalRecords)
                    case .charts:
                        ExerciseChartsTab(exercise: exercise, history: history)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(theme.colors.background)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: exercise.id) {
            // Initialize actor inside task to avoid race condition with .onAppear
            if metricsActor == nil {
                metricsActor = MetricsActor(modelContainer: modelContext.container)
            }
            await loadData()
        }
    }

    private func loadData() async {
        guard let actor = metricsActor else {
            await MainActor.run { isLoading = false }
            return
        }

        // Load history and PRs in parallel
        async let historyTask = actor.getExerciseHistory(exerciseId: exercise.id)
        async let prsTask = actor.getPersonalRecords(for: exercise.id)

        let (loadedHistory, loadedPRs) = await (historyTask, prsTask)

        await MainActor.run {
            history = loadedHistory
            personalRecords = loadedPRs
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview("ExerciseDetailView") {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise.seeded(
                name: "Barbell Bench Press",
                muscleGroup: .chest,
                equipment: .barbell,
                notes: "Keep your shoulder blades retracted."
            )
        )
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, SetEntry.self, Exercise.self])
    .environment(ThemeManager())
}
