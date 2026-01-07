import SwiftUI
import SwiftData

/// Card component displaying an exercise with its sets within a workout.
/// Redesigned with grid layout, muscle tags, drag handle, and visual set states.
struct ExerciseCardView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings
    @Environment(\.workoutManager) private var workoutManager

    @Bindable var workoutExercise: WorkoutExercise
    let exercise: Exercise
    let previousPerformance: PreviousPerformance?
    let onRemove: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: 0) {
            // Header with exercise name, tags, drag handle, menu
            exerciseHeader(theme: theme)

            // Column headers with dashed divider
            SetColumnHeaders()

            // Set rows
            VStack(spacing: 0) {
                ForEach(Array(workoutExercise.orderedSets.enumerated()), id: \.element.id) { index, set in
                    SetRowView(
                        set: set,
                        setNumber: index + 1,
                        visualState: visualState(for: set, at: index),
                        previousHint: previousSetHint(for: index),
                        onComplete: {
                            workoutManager.completeSet(
                                set,
                                autoStartTimer: settings.restTimerAutoStart,
                                timerDuration: settings.restTimerDuration
                            )
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            workoutManager.deleteSet(set, from: workoutExercise)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            // Add set footer
            addSetFooter(theme: theme)
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .strokeBorder(theme.colors.border.opacity(0.1), lineWidth: 1)
        )
        .rlShadow(theme.shadows.card)
    }

    // MARK: - Exercise Header

    private func exerciseHeader(theme: any Theme) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            // Exercise info
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text(exercise.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                // Muscle tags
                HStack(spacing: 6) {
                    ExerciseTag(text: exercise.muscleGroup.displayName.uppercased())
                    ExerciseTag(text: exercise.equipment.displayName.uppercased())
                }
            }

            Spacer()

            // Drag handle and menu
            HStack(spacing: 4) {
                // Drag handle (visual for now, will be functional with drag-drop)
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(theme.colors.textTertiary)
                    .frame(width: 32, height: 32)
                    .accessibilityLabel("Drag to reorder")
                    .accessibilityAddTraits(.isButton)

                // Menu button
                Menu {
                    Button {
                        if workoutManager.duplicateLastSet(for: workoutExercise) != nil {
                            hapticFeedback(.light)
                        }
                    } label: {
                        Label("Duplicate Last Set", systemImage: "doc.on.doc")
                    }

                    Divider()

                    Button(role: .destructive) {
                        onRemove()
                    } label: {
                        Label("Remove Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(theme.colors.textTertiary)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding(theme.spacing.md)
        .padding(.bottom, 0)
    }

    // MARK: - Add Set Footer

    private func addSetFooter(theme: any Theme) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                workoutManager.addSet(to: workoutExercise)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))

                Text("Add Set")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(theme.colors.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, theme.spacing.md)
        }
        .overlay(alignment: .top) {
            Divider()
                .background(theme.colors.divider.opacity(0.5))
        }
    }

    // MARK: - Visual State Logic

    /// Determine the visual state for a set
    private func visualState(for set: SetEntry, at index: Int) -> SetVisualState {
        if set.isCompleted { return .completed }

        // Find the first non-completed set
        let firstIncompleteIndex = workoutExercise.orderedSets.firstIndex { !$0.isCompleted }
        if index == firstIncompleteIndex { return .active }

        return .pending
    }

    // MARK: - Helpers

    private func previousSetHint(for setIndex: Int) -> PreviousSetHint? {
        guard let previous = previousPerformance,
              setIndex < previous.sets.count else { return nil }

        let set = previous.sets[setIndex]
        return PreviousSetHint(weight: set.weight, reps: set.reps)
    }

    private func hapticFeedback(_ style: HapticStyle) {
        #if os(iOS)
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        #endif
    }

    private enum HapticStyle {
        case light
    }
}

// MARK: - Exercise Tag

/// Small uppercase tag for muscle group / equipment
private struct ExerciseTag: View {
    @Environment(ThemeManager.self) private var themeManager

    let text: String

    var body: some View {
        let theme = themeManager.current

        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(theme.colors.textTertiary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(theme.colors.elevated.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(theme.colors.border.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Previous Performance Model

/// Represents previous performance data for an exercise.
struct PreviousPerformance {
    let date: Date
    let sets: [(weight: Double, reps: Int)]
    let bestSet: (weight: Double, reps: Int)?

    var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if days < 7 {
                return "\(days)d ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
        }
    }

    func formattedBestSet(unit: WeightUnit) -> String {
        guard let best = bestSet else { return "—" }
        let weightStr = best.weight.formatWeight(unit: unit, decimals: 1)
        return "\(weightStr) × \(best.reps)"
    }

    /// Create from a WorkoutExercise
    static func from(_ workoutExercise: WorkoutExercise, workoutDate: Date) -> PreviousPerformance? {
        let completedSets = workoutExercise.orderedSets.filter {
            $0.isCompleted && $0.weight != nil && $0.reps != nil
        }

        guard !completedSets.isEmpty else { return nil }

        let sets = completedSets.map { (weight: $0.weight!, reps: $0.reps!) }

        // Find best set by estimated 1RM
        let bestSet: (weight: Double, reps: Int)? = completedSets
            .max { ($0.estimated1RM ?? 0) < ($1.estimated1RM ?? 0) }
            .map { (weight: $0.weight!, reps: $0.reps!) }

        return PreviousPerformance(
            date: workoutDate,
            sets: sets,
            bestSet: bestSet
        )
    }
}

// MARK: - Preview

#Preview("ExerciseCardView") {
    let exercise = Exercise.seeded(
        name: "Barbell Squat",
        muscleGroup: .quadriceps,
        equipment: .barbell
    )

    let workoutExercise = WorkoutExercise(exerciseId: exercise.id)

    ScrollView {
        VStack(spacing: 16) {
            ExerciseCardView(
                workoutExercise: workoutExercise,
                exercise: exercise,
                previousPerformance: PreviousPerformance(
                    date: Date().addingTimeInterval(-86400 * 2),
                    sets: [(99.79, 5), (102.06, 5), (102.06, 5)],
                    bestSet: (102.06, 5)
                ),
                onRemove: {}
            )
        }
        .padding()
    }
    .background(ObsidianTheme().colors.background)
    .environment(ThemeManager())
}
