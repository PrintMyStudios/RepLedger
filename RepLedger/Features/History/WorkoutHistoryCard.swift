import SwiftUI

/// Card component for displaying a workout in the history timeline.
struct WorkoutHistoryCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let workout: Workout
    let prCount: Int

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            // Date badge
            DateBadge(date: workout.startedAt)

            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.title)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                // Stats row
                HStack(spacing: theme.spacing.sm) {
                    Label("\(workout.orderedExercises.count)", systemImage: "dumbbell.fill")
                    Label(workout.formattedDuration, systemImage: "clock.fill")
                    Label(formattedVolume, systemImage: "scalemass.fill")
                }
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()

            // PR badge
            if prCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                    Text("\(prCount)")
                        .font(theme.typography.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(theme.colors.warning)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(theme.colors.warning.opacity(0.15))
                .clipShape(Capsule())
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(workout.title), \(workout.orderedExercises.count) exercises, \(workout.formattedDuration)")
    }

    private var formattedVolume: String {
        let volume = workout.orderedExercises.reduce(0.0) { $0 + $1.totalVolume }
        return volume.formatWeight(unit: settings.liftingUnit, decimals: 0)
    }
}

/// Date badge showing day of week and day number
private struct DateBadge: View {
    @Environment(ThemeManager.self) private var themeManager

    let date: Date

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
    }

    private var dayOfWeek: String {
        Self.dayOfWeekFormatter.string(from: date).uppercased()
    }

    private var dayNumber: String {
        Self.dayNumberFormatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("WorkoutHistoryCard") {
    VStack(spacing: 12) {
        // Sample workout with PRs
        WorkoutHistoryCard(
            workout: Workout(title: "Monday Workout", startedAt: Date(), endedAt: Date()),
            prCount: 2
        )

        // Sample workout without PRs
        WorkoutHistoryCard(
            workout: Workout(
                title: "Tuesday Workout",
                startedAt: Date().addingTimeInterval(-86400),
                endedAt: Date().addingTimeInterval(-86400 + 3600)
            ),
            prCount: 0
        )
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
