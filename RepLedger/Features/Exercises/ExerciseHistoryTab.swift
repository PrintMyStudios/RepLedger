import SwiftUI

/// History tab showing workouts where the exercise was performed.
struct ExerciseHistoryTab: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let exercise: Exercise
    let history: [ExerciseHistorySummary]

    var body: some View {
        let theme = themeManager.current

        Group {
            if history.isEmpty {
                RLEmptyState.noExerciseHistory()
            } else {
                ScrollView {
                    LazyVStack(spacing: theme.spacing.sm) {
                        ForEach(history, id: \.workoutId) { item in
                            ExerciseHistoryRow(item: item, unit: settings.liftingUnit)
                        }
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
    }
}

// MARK: - History Row

private struct ExerciseHistoryRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let item: ExerciseHistorySummary
    let unit: WeightUnit

    // Cache formatters at type level to avoid per-render creation
    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            // Date badge
            VStack(spacing: 2) {
                Text(dayOfWeek)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.accent)

                Text(dayNumber)
                    .font(theme.typography.titleSmall)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.text)
            }
            .frame(width: 44, height: 44)
            .background(theme.colors.accent.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))

            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.workoutTitle)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                HStack(spacing: theme.spacing.sm) {
                    Label("\(item.setCount) sets", systemImage: "checkmark.circle.fill")

                    if let bestWeight = item.bestWeight {
                        Text("•")
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(bestWeight.formatWeight(unit: unit, decimals: 1))
                    }
                }
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()

            // Volume
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.totalVolume.formatWeight(unit: unit, decimals: 0))
                    .font(theme.typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.text)

                Text("volume")
                    .font(.caption2)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }

    private var dayOfWeek: String {
        Self.dayOfWeekFormatter.string(from: item.date).uppercased()
    }

    private var dayNumber: String {
        Self.dayNumberFormatter.string(from: item.date)
    }
}

// MARK: - Preview

#Preview("ExerciseHistoryTab") {
    ExerciseHistoryTab(
        exercise: Exercise.seeded(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell),
        history: [
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Monday Workout",
                date: Date(),
                setCount: 4,
                totalVolume: 3200,
                bestWeight: 100,
                bestE1RM: 120
            ),
            ExerciseHistorySummary(
                workoutId: UUID(),
                workoutTitle: "Push Day",
                date: Date().addingTimeInterval(-86400 * 3),
                setCount: 3,
                totalVolume: 2400,
                bestWeight: 95,
                bestE1RM: 114
            )
        ]
    )
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
