import SwiftUI
import SwiftData

/// Main Start screen for beginning workouts.
struct StartView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.workoutManager) private var workoutManager

    // MARK: - Queries

    /// Completed workouts for Continue section and duration lookup
    @Query(filter: #Predicate<Workout> { $0.endedAt != nil },
           sort: \Workout.startedAt, order: .reverse)
    private var completedWorkouts: [Workout]

    /// All templates sorted by last used
    @Query(sort: \Template.lastUsedAt, order: .reverse)
    private var templates: [Template]

    /// All exercises for starting from template
    @Query(sort: \Exercise.name)
    private var allExercises: [Exercise]

    // MARK: - State

    @State private var selectedFilter: TemplateFilter = .recent
    @State private var showTemplatePicker = false
    @State private var showTemplateEditor = false
    @State private var activeWorkout: Workout?

    // MARK: - Layout Constants

    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let cardSpacing: CGFloat = 12
    }

    // MARK: - Body

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(spacing: Layout.sectionSpacing) {
                    // Hero card with Quick Start and From Template
                    StartHeroCard(
                        onQuickStart: startEmptyWorkout,
                        onFromTemplate: { showTemplatePicker = true }
                    )

                    // Last workout section (only if last workout exists)
                    if let lastWorkout = completedWorkouts.first {
                        lastWorkoutSection(lastWorkout: lastWorkout, theme: theme)
                    }

                    // Templates section
                    templatesSection(theme: theme)
                }
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, Layout.sectionSpacing)
            }
            .background(theme.colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTabHeader(
                    title: "Start",
                    subtitle: "Begin a session in seconds"
                ) {
                    HeaderActionButton(
                        icon: "magnifyingglass",
                        action: {
                            // TODO: Search templates
                        },
                        accessibilityLabel: "Search templates"
                    )
                }
            }
            .navigationDestination(item: $activeWorkout) { _ in
                WorkoutEditorView()
                    // WorkoutEditorView has its own custom header, keep nav bar hidden
            }
            .sheet(isPresented: $showTemplatePicker) {
                TemplatePickerView { template in
                    startFromTemplate(template)
                }
            }
            .sheet(isPresented: $showTemplateEditor) {
                NavigationStack {
                    TemplateEditorView(mode: .create)
                }
            }
            .onAppear {
                // Check for active workout to resume
                if let current = workoutManager.currentWorkout {
                    activeWorkout = current
                }
            }
        }
    }

    // MARK: - Last Workout Section

    @ViewBuilder
    private func lastWorkoutSection(lastWorkout: Workout, theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("LAST WORKOUT")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(theme.colors.textTertiary)

            // Last workout card (tap to repeat)
            LastWorkoutRepeatCard(
                workout: lastWorkout,
                prCount: 0, // TODO: Calculate PR count from MetricsService
                onTap: { repeatLastWorkout(lastWorkout) }
            )
        }
    }

    // MARK: - Templates Section

    @ViewBuilder
    private func templatesSection(theme: any Theme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header with View All
            HStack {
                Text("Templates")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(theme.colors.text)

                Spacer()

                NavigationLink {
                    TemplateListView()
                } label: {
                    Text("View All")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.colors.accent)
                }
            }

            // Filter chips
            TemplateFilterChipsView(selectedFilter: $selectedFilter)

            // Templates content
            if templates.isEmpty {
                // No templates at all - show create prompt
                emptyTemplatesView(theme: theme)
            } else if filteredTemplates.isEmpty {
                // Filter yields no results - show "Show All" option
                emptyFilterView(theme: theme)
            } else {
                // Featured row (2-up)
                if !featuredTemplates.isEmpty {
                    HStack(spacing: Layout.cardSpacing) {
                        ForEach(featuredTemplates) { template in
                            TemplateFeaturedCard(
                                template: template,
                                lastWorkoutDuration: latestWorkoutByTemplateId[template.id]?.duration,
                                onTap: { startFromTemplate(template) }
                            )
                        }

                        // Add empty spacer if only 1 featured template
                        if featuredTemplates.count == 1 {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                // Template list rows (excluding featured)
                if !listTemplates.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(listTemplates) { template in
                            StartTemplateRowView(
                                template: template,
                                lastWorkoutDuration: latestWorkoutByTemplateId[template.id]?.duration,
                                onTap: { startFromTemplate(template) }
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Empty States

    @ViewBuilder
    private func emptyTemplatesView(theme: any Theme) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 40))
                .foregroundStyle(theme.colors.textTertiary)

            Text("No Templates Yet")
                .font(.headline)
                .foregroundStyle(theme.colors.text)

            Text("Create a template to quickly start workouts with your favorite exercises.")
                .font(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showTemplateEditor = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Create Template")
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.colors.textOnAccent)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(theme.colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(theme.colors.border, lineWidth: 1)
        }
    }

    @ViewBuilder
    private func emptyFilterView(theme: any Theme) -> some View {
        VStack(spacing: 12) {
            Text("No recent templates")
                .font(.headline)
                .foregroundStyle(theme.colors.text)

            Text("You haven't used any templates in the last 30 days.")
                .font(.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                selectedFilter = .all
            } label: {
                Text("Show All Templates")
                    .font(.body.weight(.medium))
                    .foregroundStyle(theme.colors.accent)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }

    // MARK: - Computed Properties

    /// Precomputed map of template ID to most recent workout using that template
    /// O(n) once, then O(1) lookups per template row
    private var latestWorkoutByTemplateId: [UUID: Workout] {
        var map: [UUID: Workout] = [:]
        for workout in completedWorkouts {
            guard let templateId = workout.templateId else { continue }
            if map[templateId] == nil {
                map[templateId] = workout // First match = most recent (already sorted)
            }
        }
        return map
    }

    /// Filtered templates based on selected chip
    private var filteredTemplates: [Template] {
        switch selectedFilter {
        case .recent:
            // Only templates used in last 30 days
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return templates.filter { ($0.lastUsedAt ?? .distantPast) > cutoff }
        case .all:
            return templates
        }
    }

    /// Featured templates (first 2 from filtered)
    private var featuredTemplates: [Template] {
        Array(filteredTemplates.prefix(2))
    }

    /// List templates (remaining after featured)
    private var listTemplates: [Template] {
        Array(filteredTemplates.dropFirst(2))
    }

    // MARK: - Actions

    private func startEmptyWorkout() {
        workoutManager.configure(modelContext: modelContext)
        let workout = workoutManager.startEmptyWorkout()
        activeWorkout = workout
    }

    private func startFromTemplate(_ template: Template) {
        workoutManager.configure(modelContext: modelContext)
        let workout = workoutManager.startFromTemplate(template, exercises: allExercises)
        activeWorkout = workout
    }

    private func repeatLastWorkout(_ workout: Workout) {
        workoutManager.configure(modelContext: modelContext)
        let newWorkout = workoutManager.startFromWorkout(workout)
        activeWorkout = newWorkout
    }
}

// MARK: - Preview

#Preview("StartView") {
    StartView()
        .environment(ThemeManager())
        .modelContainer(for: [Workout.self, Template.self, Exercise.self], inMemory: true)
}
