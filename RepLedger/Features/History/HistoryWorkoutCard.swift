import SwiftUI

/// Rich workout card for history timeline with muscle tag, PR badge, top set, and stats grid.
/// Optimized for readability with Dynamic Type support and tightened spacing.
struct HistoryWorkoutCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let workout: Workout
    let primaryMuscle: MuscleGroup?
    let prCount: Int
    let topSetInfo: TopSetInfo?
    let wasModified: Bool

    @State private var isPressed = false

    // Consistent internal spacing
    private let cardPadding: CGFloat = 14
    private let sectionSpacing: CGFloat = 10

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: 0) {
            // Header row: Muscle tag + PR badge + chevron
            headerRow

            // Title row: Workout name + datetime + Modified indicator
            titleRow

            // Top set highlight (if available)
            if let topSet = topSetInfo {
                topSetRow(topSet)
            }

            // Stats grid
            statsGrid
        }
        .padding(cardPadding)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(cardBorder, lineWidth: prCount > 0 ? 1.5 : 1)
        }
        .rlShadow(theme.shadows.card)
        .overlay {
            // PR glow effect
            if prCount > 0 {
                RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                    .fill(
                        RadialGradient(
                            colors: [theme.colors.accent.opacity(0.12), .clear],
                            center: .topTrailing,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .allowsHitTesting(false)
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Header Row

    private var headerRow: some View {
        let theme = themeManager.current

        return HStack {
            // Muscle group tag - using Dynamic Type .caption2
            if let muscle = primaryMuscle {
                Text(muscle.displayName.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(theme.colors.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.colors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Spacer()

            // PR badge - using Dynamic Type .caption
            if prCount > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)

                    Text("\(prCount) PR\(prCount > 1 ? "s" : "")")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(prCount >= 3 ? theme.colors.accentGold : theme.colors.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    (prCount >= 3 ? theme.colors.accentGold : theme.colors.accent).opacity(0.15)
                )
                .clipShape(Capsule())
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(.bottom, sectionSpacing)
    }

    // MARK: - Title Row

    private var titleRow: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: 3) {
            Text(workout.title)
                .font(.headline)
                .foregroundStyle(theme.colors.text)
                .lineLimit(1)

            HStack(spacing: 8) {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)

                if wasModified {
                    HStack(spacing: 3) {
                        Image(systemName: "pencil")
                            .font(.caption2)
                        Text("Modified")
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(theme.colors.accentOrange)
                }
            }
        }
        .padding(.bottom, sectionSpacing)
    }

    // MARK: - Top Set Row

    private func topSetRow(_ topSet: TopSetInfo) -> some View {
        let theme = themeManager.current

        return HStack(spacing: 10) {
            // Accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(theme.colors.accent)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text("Top Set")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)

                Text("\(topSet.exerciseName) \(topSet.formattedWeight(unit: settings.liftingUnit)) × \(topSet.reps)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.colors.text)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
        .padding(.bottom, sectionSpacing)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        let theme = themeManager.current

        return HStack(spacing: 0) {
            // Duration
            statItem(
                icon: "clock.fill",
                value: workout.formattedDuration,
                label: "Duration"
            )

            // Divider
            Rectangle()
                .fill(theme.colors.divider)
                .frame(width: 1, height: 36)

            // Volume
            statItem(
                icon: "scalemass.fill",
                value: formattedVolume,
                label: "Volume"
            )

            // Divider
            Rectangle()
                .fill(theme.colors.divider)
                .frame(width: 1, height: 36)

            // Exercises
            statItem(
                icon: "dumbbell.fill",
                value: "\(workout.orderedExercises.count)",
                label: "Exercises"
            )
        }
        .padding(.top, 4)
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        let theme = themeManager.current

        return VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(theme.colors.textTertiary)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.text)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Computed Properties

    private var cardBackground: Color {
        themeManager.current.colors.surface
    }

    private var cardBorder: Color {
        let theme = themeManager.current
        return prCount > 0 ? theme.colors.accent.opacity(0.3) : theme.colors.border
    }

    private var formattedVolume: String {
        let volume = workout.orderedExercises.reduce(0.0) { $0 + $1.totalVolume }
        return volume.formatWeight(unit: settings.liftingUnit, decimals: 0)
    }

    private var formattedDate: String {
        Self.dateFormatter.string(from: workout.startedAt)
    }

    private var accessibilityLabel: String {
        var parts = [workout.title, formattedDate]
        if prCount > 0 {
            parts.append("\(prCount) personal record\(prCount > 1 ? "s" : "")")
        }
        parts.append("\(workout.orderedExercises.count) exercises")
        parts.append(workout.formattedDuration)
        return parts.joined(separator: ", ")
    }

    // MARK: - Formatters

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d • h:mm a"
        return formatter
    }()
}

// MARK: - Top Set Info

struct TopSetInfo {
    let exerciseName: String
    let weight: Double
    let reps: Int
    let e1rm: Double

    func formattedWeight(unit: WeightUnit) -> String {
        weight.formatWeight(unit: unit, decimals: 1)
    }
}

// MARK: - Preview

#Preview("HistoryWorkoutCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack(spacing: 16) {
            // Card with PRs
            HistoryWorkoutCard(
                workout: Workout(title: "Push Day", startedAt: Date(), endedAt: Date()),
                primaryMuscle: .chest,
                prCount: 3,
                topSetInfo: TopSetInfo(exerciseName: "Bench Press", weight: 100, reps: 8, e1rm: 125),
                wasModified: false
            )

            // Card without PRs, modified
            HistoryWorkoutCard(
                workout: Workout(
                    title: "Upper Body",
                    startedAt: Date().addingTimeInterval(-86400),
                    endedAt: Date().addingTimeInterval(-86400 + 3600)
                ),
                primaryMuscle: .back,
                prCount: 0,
                topSetInfo: TopSetInfo(exerciseName: "Deadlift", weight: 140, reps: 5, e1rm: 163),
                wasModified: true
            )

            // Card with 1 PR
            HistoryWorkoutCard(
                workout: Workout(
                    title: "Leg Day",
                    startedAt: Date().addingTimeInterval(-172800),
                    endedAt: Date().addingTimeInterval(-172800 + 5400)
                ),
                primaryMuscle: .quadriceps,
                prCount: 1,
                topSetInfo: nil,
                wasModified: false
            )
        }
        .padding()
    }
    .environment(ThemeManager())
}
