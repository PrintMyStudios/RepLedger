import SwiftUI

struct LastWorkoutCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let workout: LastWorkoutData?
    let isLoading: Bool

    // MARK: - Computed Properties

    private var muscleGroupText: String {
        workout?.muscleGroup?.displayName ?? "Workout"
    }

    private var timeAgoText: String {
        workout?.timeAgoText ?? "—"
    }

    private var durationText: String {
        workout?.durationText ?? "—"
    }

    private var volumeText: String {
        guard let workout = workout else { return "—" }
        let converted = workout.volume.fromKg(to: settings.liftingUnit)
        if converted >= 1000 {
            return String(format: "%.1fk", converted / 1000)
        }
        return String(format: "%.0f", converted)
    }

    private var prCount: Int {
        workout?.prCount ?? 0
    }

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: 10) {
            // Header row: Label + time + chevron
            headerRow(theme: theme)

            // Muscle tag (if available)
            if let muscleGroup = workout?.muscleGroup {
                Text(muscleGroup.displayName.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(theme.colors.elevated)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .redacted(reason: isLoading ? .placeholder : [])
            }

            // Stats row
            statsRow(theme: theme)
        }
        .padding(DashboardTokens.cardPadding)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: DashboardTokens.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DashboardTokens.cornerRadius)
                .stroke(theme.colors.border.opacity(DashboardTokens.cardBorderOpacity), lineWidth: 1)
        }
        .rlShadow(theme.shadows.card)
    }

    // MARK: - Header Row

    @ViewBuilder
    private func headerRow(theme: any Theme) -> some View {
        HStack {
            Text("LATEST WORKOUT")
                .font(DashboardTokens.sectionLabel)
                .tracking(1.0)
                .foregroundStyle(theme.colors.textTertiary)

            Spacer()

            HStack(spacing: 4) {
                Text(timeAgoText)
                    .font(DashboardTokens.secondaryText)
                    .foregroundStyle(theme.colors.textSecondary)

                // Only show chevron when workout exists (card is tappable)
                if workout != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            .redacted(reason: isLoading ? .placeholder : [])
        }
    }

    // MARK: - Stats Row

    @ViewBuilder
    private func statsRow(theme: any Theme) -> some View {
        HStack(spacing: 0) {
            // Duration
            StatItem(
                label: "DURATION",
                value: durationText,
                icon: "clock",
                valueColor: nil,
                theme: theme
            )
            .frame(maxWidth: .infinity)
            .redacted(reason: isLoading ? .placeholder : [])

            // Divider
            Rectangle()
                .fill(theme.colors.divider)
                .frame(width: 1, height: 32)

            // Volume
            StatItem(
                label: "VOL",
                value: volumeText,
                icon: "dumbbell.fill",
                valueColor: nil,
                theme: theme
            )
            .frame(maxWidth: .infinity)
            .redacted(reason: isLoading ? .placeholder : [])

            // Divider
            Rectangle()
                .fill(theme.colors.divider)
                .frame(width: 1, height: 32)

            // PRs
            StatItem(
                label: "PRS",
                value: prCount > 0 ? "\(prCount) PRs" : "None",
                icon: "trophy.fill",
                valueColor: prCount > 0 ? theme.colors.accent : nil,
                theme: theme
            )
            .frame(maxWidth: .infinity)
            .redacted(reason: isLoading ? .placeholder : [])
        }
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    let valueColor: Color?
    let theme: any Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(theme.colors.textTertiary)

            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(valueColor ?? theme.colors.textTertiary)

                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(valueColor ?? theme.colors.textSecondary)
            }
        }
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack(spacing: 16) {
            // Loading state
            LastWorkoutCard(workout: nil, isLoading: true)

            // Real data
            LastWorkoutCard(
                workout: LastWorkoutData(
                    id: UUID(),
                    muscleGroup: .chest,
                    date: Date(),
                    durationSeconds: 4500,
                    volume: 12400,
                    prCount: 3
                ),
                isLoading: false
            )

            // No PRs
            LastWorkoutCard(
                workout: LastWorkoutData(
                    id: UUID(),
                    muscleGroup: .back,
                    date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                    durationSeconds: 3600,
                    volume: 8500,
                    prCount: 0
                ),
                isLoading: false
            )
        }
        .padding()
    }
    .environment(ThemeManager())
}
