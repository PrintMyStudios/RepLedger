import SwiftUI
import SwiftData

// MARK: - Spacing Constants

/// Consistent spacing values for the History screen
private enum HistorySpacing {
    static let horizontalPadding: CGFloat = 16
    static let sectionGap: CGFloat = 24
    static let cardGap: CGFloat = 12
    static let innerPadding: CGFloat = 12
    static let compactGap: CGFloat = 8
}

/// Main history timeline view showing completed workouts with rich filtering and stats.
struct HistoryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Workout.startedAt, order: .reverse) private var allWorkouts: [Workout]
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Query(sort: \Template.name) private var templates: [Template]

    @State private var filterState = HistoryFilterState()
    @State private var showFilterSheet = false
    @State private var exerciseNameCache: [UUID: String] = [:]
    @State private var exerciseMuscleCache: [UUID: MuscleGroup] = [:]
    @State private var metricsActor: MetricsActor?
    @State private var weeklyStats: HistoryWeeklyStats = .empty
    @State private var isStatsLoaded = false

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ZStack {
                theme.colors.background.ignoresSafeArea()

                if completedWorkouts.isEmpty {
                    RLEmptyState.noWorkouts {
                        // TODO: Navigate to Start tab
                    }
                } else if filteredWorkouts.isEmpty {
                    RLEmptyState.noSearchResults(query: filterState.searchText)
                } else {
                    mainContent
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTabHeader(
                    title: "History",
                    subtitle: "\(completedWorkouts.count) workout\(completedWorkouts.count == 1 ? "" : "s") completed"
                ) {
                    HeaderActionButton(
                        icon: "magnifyingglass",
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                filterState.isSearching = true
                            }
                        },
                        accessibilityLabel: "Search history"
                    )
                    HeaderActionButton(
                        icon: "line.3.horizontal.decrease",
                        action: { showFilterSheet = true },
                        badge: filterState.hasActiveFilters ? .activeFilter : nil,
                        accessibilityLabel: "Filter workouts"
                    )
                }
            }
            .overlay {
                // Search overlay
                if filterState.isSearching {
                    searchOverlay
                }
            }
            .navigationDestination(for: Workout.self) { workout in
                WorkoutDetailView(workout: workout)
                    .toolbar(.visible, for: .navigationBar)
            }
            .task {
                if metricsActor == nil {
                    metricsActor = MetricsActor(modelContainer: modelContext.container)
                }
                loadCaches()
                await loadWeeklyStats()
            }
            .sheet(isPresented: $showFilterSheet) {
                HistoryFilterSheet(filterState: filterState)
            }
        }
    }

    // MARK: - Search Overlay

    private var searchOverlay: some View {
        let theme = themeManager.current

        return VStack(spacing: 0) {
            // Search bar
            HStack(spacing: HistorySpacing.innerPadding) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.colors.textTertiary)

                TextField("Search exercises, workouts...", text: $filterState.searchText)
                    .font(.body)
                    .foregroundStyle(theme.colors.text)
                    .submitLabel(.search)
                    .autocorrectionDisabled()

                if !filterState.searchText.isEmpty {
                    Button {
                        filterState.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                    .frame(width: 44, height: 44)
                }

                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterState.searchText = ""
                        filterState.isSearching = false
                    }
                }
                .font(.body.weight(.medium))
                .foregroundStyle(theme.colors.accent)
            }
            .padding(.horizontal, HistorySpacing.horizontalPadding)
            .padding(.vertical, HistorySpacing.innerPadding)
            .background(theme.colors.surface)

            Divider()
                .background(theme.colors.divider)

            Spacer()
        }
        .background(theme.colors.background.opacity(0.98))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Main Content

    private var mainContent: some View {
        let theme = themeManager.current

        return ScrollView {
            LazyVStack(spacing: 0) {
                // Weekly insights card - only visible after stats load to prevent flicker
                HistoryInsightsCard(
                    stats: weeklyStats,
                    isThisWeekSelected: filterState.selectedPeriod == .week,
                    onThisWeekTap: {
                        filterState.selectedPeriod = filterState.selectedPeriod == .week ? .all : .week
                    }
                )
                .opacity(isStatsLoaded ? 1 : 0)
                .padding(.horizontal, HistorySpacing.horizontalPadding)
                .padding(.top, HistorySpacing.innerPadding)
                .padding(.bottom, HistorySpacing.cardGap)

                // Filter chips
                HistoryFilterChipsView(selectedPeriod: $filterState.selectedPeriod)
                    .padding(.bottom, HistorySpacing.sectionGap)

                // Workout sections
                workoutSections
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Workout Sections

    private var workoutSections: some View {
        LazyVStack(spacing: HistorySpacing.sectionGap) {
            ForEach(groupedWorkouts) { group in
                VStack(spacing: HistorySpacing.cardGap) {
                    // Section header
                    CollapsibleSectionHeader(
                        title: group.section.displayTitle,
                        statsText: group.statsText,
                        isCollapsed: filterState.isSectionCollapsed(group.section),
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                filterState.toggleSection(group.section)
                            }
                        }
                    )
                    .padding(.horizontal, HistorySpacing.horizontalPadding)

                    // Workout cards (collapsible)
                    if !filterState.isSectionCollapsed(group.section) {
                        VStack(spacing: HistorySpacing.cardGap) {
                            ForEach(group.workouts) { workout in
                                NavigationLink(value: workout) {
                                    LazyHistoryWorkoutCard(
                                        workout: workout,
                                        exerciseNameCache: exerciseNameCache,
                                        exerciseMuscleCache: exerciseMuscleCache,
                                        templates: templates,
                                        metricsActor: metricsActor
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, HistorySpacing.horizontalPadding)
                    }
                }
            }

            // End marker
            HistoryEndMarker(totalWorkouts: completedWorkouts.count)
                .padding(.horizontal, HistorySpacing.horizontalPadding)
                .padding(.top, HistorySpacing.cardGap)
        }
    }

    // MARK: - Data Helpers

    private var completedWorkouts: [Workout] {
        allWorkouts.filter { $0.endedAt != nil }
    }

    private var filteredWorkouts: [Workout] {
        var workouts = completedWorkouts

        // Search filter
        if !filterState.searchText.isEmpty {
            let searchLower = filterState.searchText.lowercased()
            workouts = workouts.filter { workout in
                // Search by workout title
                if workout.title.lowercased().contains(searchLower) {
                    return true
                }
                // Search by exercise name
                return workout.orderedExercises.contains { we in
                    exerciseNameCache[we.exerciseId]?.lowercased().contains(searchLower) ?? false
                }
            }
        }

        // Time period filter
        let calendar = Calendar.current
        let now = Date()

        switch filterState.selectedPeriod {
        case .all:
            break
        case .week:
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start {
                workouts = workouts.filter { $0.startedAt >= weekStart }
            }
        case .month:
            if let monthStart = calendar.dateInterval(of: .month, for: now)?.start {
                workouts = workouts.filter { $0.startedAt >= monthStart }
            }
        case .prsOnly:
            // Will be filtered later with PR data
            break
        case .templates:
            workouts = workouts.filter { $0.templateId != nil }
        }

        // Muscle group filter
        if !filterState.selectedMuscleGroups.isEmpty {
            workouts = workouts.filter { workout in
                workout.orderedExercises.contains { we in
                    if let muscle = exerciseMuscleCache[we.exerciseId] {
                        return filterState.selectedMuscleGroups.contains(muscle)
                    }
                    return false
                }
            }
        }

        // Template filter
        if !filterState.selectedTemplateIds.isEmpty {
            workouts = workouts.filter { workout in
                if let templateId = workout.templateId {
                    return filterState.selectedTemplateIds.contains(templateId)
                }
                return false
            }
        }

        // Date range filter
        if let startDate = filterState.startDate {
            workouts = workouts.filter { $0.startedAt >= startDate }
        }
        if let endDate = filterState.endDate {
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
            workouts = workouts.filter { $0.startedAt < endOfDay }
        }

        return workouts
    }

    private var groupedWorkouts: [HistorySectionGroup] {
        let calendar = Calendar.current
        let now = Date()

        // Get week boundaries
        guard let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return []
        }
        let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: thisWeekStart) ?? thisWeekStart

        // Group workouts
        var groups: [HistorySectionType: [Workout]] = [:]

        for workout in filteredWorkouts {
            let section: HistorySectionType
            let workoutDate = workout.startedAt

            if workoutDate >= thisWeekStart {
                section = .thisWeek
            } else if workoutDate >= lastWeekStart {
                section = .lastWeek
            } else {
                let components = calendar.dateComponents([.year, .month], from: workoutDate)
                section = .month(year: components.year ?? 1970, month: components.month ?? 1)
            }

            groups[section, default: []].append(workout)
        }

        // Convert to sorted array
        return groups.map { section, workouts in
            let totalVolume = workouts.reduce(0.0) { $0 + $1.totalVolume }
            return HistorySectionGroup(
                section: section,
                workouts: workouts,
                sessionCount: workouts.count,
                totalVolume: totalVolume
            )
        }
        .sorted { $0.section < $1.section }
    }

    // MARK: - Data Loading

    private func loadCaches() {
        exerciseNameCache = Dictionary(
            uniqueKeysWithValues: exercises.map { ($0.id, $0.name) }
        )
        exerciseMuscleCache = Dictionary(
            uniqueKeysWithValues: exercises.map { ($0.id, $0.muscleGroup) }
        )
    }

    private func loadWeeklyStats() async {
        guard let actor = metricsActor else { return }
        let stats = await actor.getWeeklyStats()
        weeklyStats = stats
        isStatsLoaded = true
    }
}

// MARK: - Lazy History Workout Card

/// Wrapper that loads PR count and other data lazily when card appears
private struct LazyHistoryWorkoutCard: View {
    let workout: Workout
    let exerciseNameCache: [UUID: String]
    let exerciseMuscleCache: [UUID: MuscleGroup]
    let templates: [Template]
    let metricsActor: MetricsActor?

    @State private var prCount: Int = 0

    var body: some View {
        HistoryWorkoutCard(
            workout: workout,
            primaryMuscle: primaryMuscle,
            prCount: prCount,
            topSetInfo: topSetInfo,
            wasModified: wasModified
        )
        .task {
            guard let actor = metricsActor else { return }
            prCount = await actor.countPRsInWorkout(workout.id)
        }
    }

    private var primaryMuscle: MuscleGroup? {
        // Get the most common muscle group from exercises
        var muscleCount: [MuscleGroup: Int] = [:]

        for we in workout.orderedExercises {
            if let muscle = exerciseMuscleCache[we.exerciseId] {
                muscleCount[muscle, default: 0] += 1
            }
        }

        return muscleCount.max(by: { $0.value < $1.value })?.key
    }

    private var topSetInfo: TopSetInfo? {
        guard let top = workout.topSet,
              let weight = top.set.weight,
              let reps = top.set.reps,
              let e1rm = top.set.estimated1RM,
              let exerciseName = exerciseNameCache[top.workoutExercise.exerciseId] else {
            return nil
        }

        return TopSetInfo(
            exerciseName: exerciseName,
            weight: weight,
            reps: reps,
            e1rm: e1rm
        )
    }

    private var wasModified: Bool {
        guard let templateId = workout.templateId else { return false }
        let template = templates.first { $0.id == templateId }
        return workout.wasModifiedFromTemplate(template)
    }
}

// MARK: - Preview

#Preview("HistoryView") {
    HistoryView()
        .modelContainer(for: [Workout.self, WorkoutExercise.self, SetEntry.self, Exercise.self, Template.self])
        .environment(ThemeManager())
}
