import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.userSettings) private var settings

    @State private var persistenceService: PersistenceService?

    var body: some View {
        let theme = themeManager.current

        Group {
            if settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(colorScheme(for: themeManager.currentID))
        .tint(theme.colors.accent)
        .onAppear {
            // Initialize persistence service and seed exercises
            persistenceService = PersistenceService(modelContext: modelContext)
            persistenceService?.seedExercisesIfNeeded()
        }
    }

    private func colorScheme(for themeId: ThemeID) -> ColorScheme {
        switch themeId {
        case .obsidian, .forge:
            return .dark
        case .studio:
            return .light
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager
    // TODO: Milestone 5 - Add isCoach check for Coach tab visibility

    var body: some View {
        let theme = themeManager.current

        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            StartWorkoutView()
                .tabItem {
                    Label("Start", systemImage: "plus.circle.fill")
                }

            ExerciseLibraryView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(theme.colors.accent)
    }
}

// MARK: - Tab Views

struct DashboardView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    // Quick stats
                    RLCard {
                        RLStatGrid {
                            RLStatTile.workouts(0)
                            RLStatTile.volume("0 kg")
                        }
                    }

                    // Empty state
                    RLEmptyState.noWorkouts {
                        // TODO: Start workout
                    }
                }
                .padding(theme.spacing.md)
            }
            .background(theme.colors.background)
            .navigationTitle("Dashboard")
        }
    }
}

struct HistoryView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            RLEmptyState.noWorkouts {
                // TODO: Navigate to start workout
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.background)
            .navigationTitle("History")
        }
    }
}

struct StartWorkoutView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(theme.colors.accent)

                Text("Start Workout")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("Begin an empty workout or\nchoose a template")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)

                VStack(spacing: theme.spacing.md) {
                    RLButton("Quick Start", icon: "bolt.fill") {
                        // TODO: Milestone 2 - Start empty workout
                    }

                    RLButton("From Template", icon: "doc.on.doc", style: .secondary) {
                        // TODO: Milestone 2 - Show template picker
                    }
                }
                .padding(.horizontal, theme.spacing.xl)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(theme.colors.background)
            .navigationTitle("Start")
        }
    }
}

struct ExerciseLibraryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @State private var searchText = ""

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            Group {
                if exercises.isEmpty {
                    RLEmptyState(
                        icon: "dumbbell.fill",
                        title: "Loading Exercises",
                        subtitle: "Exercise library is being set up..."
                    )
                } else if filteredExercises.isEmpty {
                    RLEmptyState.noSearchResults(query: searchText)
                } else {
                    List {
                        ForEach(MuscleGroup.allCases) { group in
                            let groupExercises = filteredExercises.filter { $0.muscleGroup == group }
                            if !groupExercises.isEmpty {
                                Section {
                                    ForEach(groupExercises) { exercise in
                                        ExerciseRow(exercise: exercise)
                                    }
                                } header: {
                                    Text(group.displayName)
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(theme.colors.background)
            .navigationTitle("Exercises")
            .searchable(text: $searchText, prompt: "Search exercises")
        }
    }

    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

struct ExerciseRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            Image(systemName: exercise.muscleGroup.icon)
                .font(.title3)
                .foregroundStyle(theme.colors.accent)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.text)

                Text(exercise.equipment.displayName)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(exercise.name), \(exercise.muscleGroup.displayName), \(exercise.equipment.displayName)")
    }
}

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            List {
                // Units section
                Section("Units") {
                    Picker("Lifting Weight", selection: Binding(
                        get: { settings.liftingUnit },
                        set: { settings.liftingUnit = $0 }
                    )) {
                        ForEach(WeightUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }

                    Picker("Bodyweight Display", selection: Binding(
                        get: { settings.bodyweightUnit },
                        set: { settings.bodyweightUnit = $0 }
                    )) {
                        ForEach(BodyweightUnit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                }

                // Theme section
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.currentID },
                        set: {
                            themeManager.setTheme($0)
                            settings.selectedTheme = $0
                        }
                    )) {
                        ForEach(ThemeID.allCases) { themeId in
                            Text(themeId.displayName).tag(themeId)
                        }
                    }
                }

                // Rest timer section
                Section("Rest Timer") {
                    Picker("Default Duration", selection: Binding(
                        get: { settings.restTimerDuration },
                        set: { settings.restTimerDuration = $0 }
                    )) {
                        ForEach(UserSettings.restTimerPresets, id: \.self) { seconds in
                            Text(formatDuration(seconds)).tag(seconds)
                        }
                    }

                    Toggle("Auto-start after set", isOn: Binding(
                        get: { settings.restTimerAutoStart },
                        set: { settings.restTimerAutoStart = $0 }
                    ))
                }

                // Pro section
                Section("Pro") {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                        .foregroundStyle(theme.colors.textSecondary)
                    // TODO: Milestone 4 - Pro paywall

                    Label("Backup & Sync", systemImage: "icloud.fill")
                        .foregroundStyle(theme.colors.textSecondary)
                    // TODO: Milestone 4 - Pro paywall
                }

                // Account section
                Section("Account") {
                    Button {
                        // TODO: Milestone 4 - Restore purchases
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                    }
                }

                // About section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.colors.background)
            .navigationTitle("Settings")
            .tint(theme.colors.accent)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if minutes > 0 && secs > 0 {
            return "\(minutes)m \(secs)s"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(secs) sec"
        }
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager())
}
