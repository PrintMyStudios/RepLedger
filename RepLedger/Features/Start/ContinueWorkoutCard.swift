import SwiftUI

/// Card showing the last workout with tap-to-repeat functionality.
struct LastWorkoutRepeatCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let workout: Workout
    let prCount: Int
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            HStack(spacing: 12) {
                // Repeat icon in circle
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.colors.accent)
                    .frame(width: 40, height: 40)
                    .background(theme.colors.accent.opacity(0.15))
                    .clipShape(Circle())

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    // Title row with optional muscle tag
                    HStack(spacing: 8) {
                        Text(workout.title)
                            .font(.headline)
                            .foregroundStyle(theme.colors.text)
                            .lineLimit(1)

                        if let primaryMuscle = determinePrimaryMuscle() {
                            Text(primaryMuscle.displayName.uppercased())
                                .font(.caption2.weight(.bold))
                                .tracking(0.5)
                                .foregroundStyle(theme.colors.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(theme.colors.elevated)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    // Meta row
                    HStack(spacing: 0) {
                        Text(formattedDate)

                        Text(" • ")

                        Text(workout.formattedDuration)

                        Text(" • ")

                        Text(formattedVolume)

                        if prCount > 0 {
                            Text(" • ")

                            HStack(spacing: 2) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption2)
                                Text("\(prCount) PR\(prCount > 1 ? "s" : "")")
                            }
                            .foregroundStyle(theme.colors.accentGold)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()

                // Arrow in accent circle (indicates tap-to-repeat action)
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(theme.colors.textOnAccent)
                    .frame(width: 28, height: 28)
                    .background(theme.colors.accent)
                    .clipShape(Circle())
            }
            .padding(16)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(workout.title), tap to repeat")
        .accessibilityHint("Start a new workout with the same exercises")
    }

    // MARK: - Computed Properties

    private var formattedDate: String {
        workout.startedAt.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    private var formattedVolume: String {
        let volume = workout.totalVolume
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return String(format: "%.0f", volume)
    }

    /// Determine the primary muscle group from the workout's exercises
    private func determinePrimaryMuscle() -> MuscleGroup? {
        // Count exercises per muscle group
        var counts: [MuscleGroup: Int] = [:]

        for exercise in workout.orderedExercises {
            // We'd need to resolve the exerciseId to get the muscle group
            // For now, return nil - this can be enhanced later
        }

        // Return the most common muscle group
        return counts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Preview

#Preview("LastWorkoutRepeatCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack(spacing: 16) {
            // With PRs
            LastWorkoutRepeatCard(
                workout: Workout(
                    title: "Upper Body A",
                    startedAt: Date().addingTimeInterval(-86400),
                    endedAt: Date().addingTimeInterval(-86400 + 4500)
                ),
                prCount: 3,
                onTap: { print("Tapped") }
            )

            // Without PRs
            LastWorkoutRepeatCard(
                workout: Workout(
                    title: "Leg Day",
                    startedAt: Date().addingTimeInterval(-172800),
                    endedAt: Date().addingTimeInterval(-172800 + 3600)
                ),
                prCount: 0,
                onTap: { print("Tapped") }
            )
        }
        .padding(.horizontal, 20)
    }
    .environment(ThemeManager())
}
