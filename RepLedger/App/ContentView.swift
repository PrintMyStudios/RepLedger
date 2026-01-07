import SwiftUI
import SwiftData

// MARK: - Tab Bar Metrics (Single Source of Truth)

/// Centralized metrics for the custom tab bar to ensure consistent insets across all screens.
enum TabBarMetrics {
    /// Height of the tab bar itself
    static let barHeight: CGFloat = 60

    /// Size of the floating center button
    static let fabSize: CGFloat = 56

    /// How far the FAB extends above the bar (negative offset)
    static let fabOffset: CGFloat = 20

    /// Extra clearance above the FAB for comfortable tapping
    static let fabClearance: CGFloat = 8

    /// Total height the tab bar occupies (bar + FAB overhang + clearance)
    /// This is used by .safeAreaInset to inset content correctly
    static var totalHeight: CGFloat {
        // FAB extends (fabSize/2 - fabOffset) above bar top = 28 - 20 = 8pt
        // Plus clearance = 8pt more
        // Total above bar = 16pt
        barHeight + fabClearance + (fabSize / 2 - fabOffset)
    }
}

struct ContentView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.userSettings) private var settings
    @Environment(\.purchaseManager) private var purchaseManager

    @State private var persistenceService: PersistenceService?
    @State private var workoutManager = WorkoutManager()
    @State private var showProUpsell = false

    var body: some View {
        let theme = themeManager.current

        Group {
            if settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environment(\.workoutManager, workoutManager)
        .preferredColorScheme(colorScheme(for: themeManager.currentID))
        .tint(theme.colors.accent)
        .onAppear {
            // Initialize persistence service and seed exercises
            persistenceService = PersistenceService(modelContext: modelContext)
            persistenceService?.seedExercisesIfNeeded()

            // Configure workout manager with model context
            workoutManager.configure(modelContext: modelContext)
        }
        .onChange(of: settings.completedWorkoutCount) { _, newValue in
            // Trigger soft upsell when >= 3 workouts AND not shown before AND not Pro
            if newValue >= 3 && !settings.hasShownProUpsell && !purchaseManager.isPro {
                showProUpsell = true
            }
        }
        .sheet(isPresented: $showProUpsell) {
            ProUpsellSheet()
                .presentationDetents([.medium])
                .onDisappear {
                    settings.hasShownProUpsell = true
                }
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

enum MainTab: Int, CaseIterable {
    case dashboard
    case history
    case start
    case exercises
    case settings
}

struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.purchaseManager) private var purchaseManager

    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        let theme = themeManager.current

        // Tab content with safe area inset for custom tab bar
        // This automatically insets all child ScrollViews and Lists
        Group {
            switch selectedTab {
            case .dashboard:
                DashboardView(selectedTab: $selectedTab)
            case .history:
                HistoryView()
            case .start:
                StartView()
            case .exercises:
                ExerciseLibraryView()
            case .settings:
                SettingsView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(selectedTab: $selectedTab, theme: theme, isCoach: purchaseManager.isCoach)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    let theme: any Theme
    let isCoach: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Main bar content with floating button
            ZStack {
                // Bar background with tabs
                HStack(spacing: 0) {
                    // Left tabs
                    tabButton(tab: .dashboard, icon: "house.fill", label: "Home")
                    tabButton(tab: .history, icon: "clock.fill", label: "History")

                    // Center spacer for floating button
                    Spacer()
                        .frame(width: TabBarMetrics.fabSize + 16)

                    // Right tabs
                    tabButton(tab: .exercises, icon: "dumbbell.fill", label: "Exercises")
                    tabButton(tab: .settings, icon: "gearshape.fill", label: "Settings")
                }
                .frame(height: TabBarMetrics.barHeight)

                // Floating center button
                Button {
                    selectedTab = .start
                } label: {
                    ZStack {
                        Circle()
                            .fill(theme.colors.accent)
                            .frame(width: TabBarMetrics.fabSize, height: TabBarMetrics.fabSize)
                            .shadow(color: .black.opacity(0.25), radius: 8, y: 4)

                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(theme.colors.textOnAccent)
                    }
                }
                .offset(y: -TabBarMetrics.fabOffset)
            }
        }
        // Opaque background that extends into safe area (home indicator area)
        .background(
            theme.colors.surface
                .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(tab: MainTab, icon: String, label: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))

                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(selectedTab == tab ? theme.colors.accent : theme.colors.textSecondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Views

struct DashboardView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings
    @Environment(\.modelContext) private var modelContext

    @Binding var selectedTab: MainTab

    // Query all workouts for navigation destination lookup
    @Query private var workouts: [Workout]

    // MARK: - State
    @State private var dashboardData: DashboardData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var metricsActor: MetricsActor?

    // MARK: - Layout Constants
    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let cardSpacing: CGFloat = 16
        static let smallCardSpacing: CGFloat = 12
        static let ctaHeight: CGFloat = 52
    }

    /// Reload trigger: combine settings that affect display
    private var reloadTrigger: String {
        "\(settings.weeklySessionsGoal)-\(settings.liftingUnit.rawValue)"
    }

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.cardSpacing) {
                    // Start Workout CTA - navigates to Start tab
                    startWorkoutButton(theme: theme)

                    // Content based on loading/empty state
                    if isLoading && dashboardData == nil {
                        // First load: show loading placeholders
                        loadingContent
                    } else if let data = dashboardData {
                        if !data.hasAnyWorkouts {
                            // Empty state
                            DashboardEmptyStateCard(onStartWorkout: { selectedTab = .start })
                        } else {
                            // Real data
                            dataContent(data: data)
                        }
                    } else {
                        // Still loading but no data yet
                        loadingContent
                    }
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.cardSpacing)
            }
            .background(theme.colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                DashboardHeaderView(userName: settings.userName)
            }
            .navigationDestination(for: UUID.self) { workoutId in
                // Find workout by ID and navigate to detail
                if let workout = workouts.first(where: { $0.id == workoutId }) {
                    WorkoutDetailView(workout: workout)
                        .toolbar(.visible, for: .navigationBar)
                }
            }
        }
        .task(id: reloadTrigger) {
            await load()
        }
        .refreshable {
            await load()
        }
    }

    // MARK: - Data Loading

    private func load() async {
        if metricsActor == nil {
            metricsActor = MetricsActor(modelContainer: modelContext.container)
        }
        guard let actor = metricsActor else { return }

        // Don't wipe existing data during refresh
        if dashboardData == nil {
            isLoading = true
        }

        let data = await actor.getDashboardData(sessionsGoal: settings.weeklySessionsGoal)
        dashboardData = data
        errorMessage = nil
        isLoading = false
    }

    // MARK: - Content States

    @ViewBuilder
    private var loadingContent: some View {
        DashboardStatsCard(stats: nil, weeklyVolumeByDay: [], isLoading: true)
        LastWorkoutCard(workout: nil, isLoading: true)
        HStack(spacing: Layout.smallCardSpacing) {
            RecoveryCard(recovery: [], isLoading: true)
            LatestPRCard(latestPR: nil, isLoading: true)
        }
    }

    @ViewBuilder
    private func dataContent(data: DashboardData) -> some View {
        DashboardStatsCard(
            stats: data.stats,
            weeklyVolumeByDay: data.weeklyVolumeByDay,
            isLoading: isLoading
        )

        if let lastWorkout = data.lastWorkout {
            NavigationLink(value: lastWorkout.id) {
                LastWorkoutCard(workout: lastWorkout, isLoading: isLoading)
            }
            .buttonStyle(.plain)
        }

        HStack(spacing: Layout.smallCardSpacing) {
            RecoveryCard(recovery: data.recovery, isLoading: isLoading)
            LatestPRCard(latestPR: data.latestPR, isLoading: isLoading)
        }
    }

    // MARK: - Buttons

    @ViewBuilder
    private func startWorkoutButton(theme: any Theme) -> some View {
        Button {
            selectedTab = .start
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                Text("Start Workout")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(theme.colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.ctaHeight)
            .background(theme.colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .rlShadow(theme.shadows.neonGlow)
        }
        .buttonStyle(.plain)
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
                                        NavigationLink(value: exercise) {
                                            ExerciseRow(exercise: exercise)
                                        }
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
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTabHeader(title: "Exercises")
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
                    .toolbar(.visible, for: .navigationBar)
            }
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
    @Environment(\.purchaseManager) private var purchaseManager

    @State private var showProPaywall = false
    @State private var isRestoring = false

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            List {
                // Templates section
                Section("Workout") {
                    NavigationLink {
                        TemplateListView()
                    } label: {
                        Label("My Templates", systemImage: "doc.text.fill")
                    }

                    Picker("Weekly Goal", selection: Binding(
                        get: { settings.weeklySessionsGoal },
                        set: { settings.weeklySessionsGoal = $0 }
                    )) {
                        ForEach(3...7, id: \.self) { goal in
                            Text("\(goal) workouts").tag(goal)
                        }
                    }
                }

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
                    Button {
                        if purchaseManager.isPro {
                            // TODO: Implement export functionality
                        } else {
                            showProPaywall = true
                        }
                    } label: {
                        HStack {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                            Spacer()
                            if !purchaseManager.isPro {
                                RLPill("PRO", style: .filled, size: .small)
                            }
                        }
                    }
                    .foregroundStyle(theme.colors.text)

                    Button {
                        if purchaseManager.isPro {
                            // TODO: Implement backup settings
                        } else {
                            showProPaywall = true
                        }
                    } label: {
                        HStack {
                            Label("Backup & Sync", systemImage: "icloud.fill")
                            Spacer()
                            if !purchaseManager.isPro {
                                RLPill("PRO", style: .filled, size: .small)
                            }
                        }
                    }
                    .foregroundStyle(theme.colors.text)
                }

                // Account section
                Section("Account") {
                    Button {
                        Task {
                            isRestoring = true
                            await purchaseManager.restorePurchases()
                            isRestoring = false
                        }
                    } label: {
                        HStack {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                            if isRestoring {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRestoring)
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
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTabHeader(title: "Settings")
            }
            .tint(theme.colors.accent)
            .sheet(isPresented: $showProPaywall) {
                ProPaywallView()
            }
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
