import SwiftUI

/// Stats grid showing workout summary metrics.
/// Used in WorkoutDetailView to display duration, sets, volume, and PRs.
struct WorkoutSummaryStats: View {
    @Environment(\.userSettings) private var settings

    let workout: Workout
    let prCount: Int

    var body: some View {
        RLCard {
            RLStatGrid(columns: 2) {
                RLStatTile.duration(workout.formattedDuration)
                RLStatTile(
                    value: "\(workout.completedSetCount)",
                    label: "Sets",
                    icon: "checkmark.circle.fill"
                )
                RLStatTile.volume(formattedVolume)
                RLStatTile.prs(prCount)
            }
        }
    }

    private var formattedVolume: String {
        let volume = workout.orderedExercises.reduce(0.0) { $0 + $1.totalVolume }
        return volume.formatWeight(unit: settings.liftingUnit, decimals: 0)
    }
}

// MARK: - Preview

#Preview("WorkoutSummaryStats") {
    WorkoutSummaryStats(
        workout: Workout(
            title: "Monday Workout",
            startedAt: Date().addingTimeInterval(-3600),
            endedAt: Date()
        ),
        prCount: 2
    )
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
