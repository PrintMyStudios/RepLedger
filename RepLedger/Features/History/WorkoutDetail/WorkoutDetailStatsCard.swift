import SwiftUI

/// 6-stat summary card for workout detail view
/// Layout: Volume | Sets | PRs (row 1), Exercises | Duration | Notes (row 2)
struct WorkoutDetailStatsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let volume: Double
    let setCount: Int
    let prCount: Int
    let exerciseCount: Int
    let duration: TimeInterval
    let hasNotes: Bool

    var onNotesReadTap: (() -> Void)?

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: 0) {
            // Row 1: Volume | Sets | PRs
            HStack(spacing: 0) {
                statCell(
                    label: "VOLUME",
                    value: formattedVolume,
                    unit: settings.liftingUnit.abbreviation,
                    color: theme.colors.text,
                    showBorder: true
                )

                statCell(
                    label: "SETS",
                    value: "\(setCount)",
                    unit: nil,
                    color: theme.colors.text,
                    showBorder: true
                )

                prStatCell
            }

            Divider()
                .background(theme.colors.divider.opacity(0.5))

            // Row 2: Exercises | Duration | Notes
            HStack(spacing: 0) {
                iconStatCell(
                    label: "EXERCISES",
                    icon: "dumbbell.fill",
                    value: "\(exerciseCount)"
                )

                iconStatCell(
                    label: "DURATION",
                    icon: "clock.fill",
                    value: formattedDuration
                )

                notesStatCell
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(theme.colors.border, lineWidth: 1)
        }
        .rlShadow(theme.shadows.card)
    }

    // MARK: - Stat Cells

    private func statCell(label: String, value: String, unit: String?, color: Color, showBorder: Bool) -> some View {
        let theme = themeManager.current

        return VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(theme.colors.textTertiary)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(color)

                if let unit = unit {
                    Text(unit)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.md)
        .overlay(alignment: .trailing) {
            if showBorder {
                Rectangle()
                    .fill(theme.colors.divider.opacity(0.5))
                    .frame(width: 1)
            }
        }
    }

    private var prStatCell: some View {
        let theme = themeManager.current

        return VStack(spacing: 4) {
            Text("PRS")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(theme.colors.accentGold)

            HStack(spacing: 4) {
                Image(systemName: "trophy.fill")
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.accentGold)

                Text("\(prCount)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.colors.text)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.md)
    }

    private func iconStatCell(label: String, icon: String, value: String) -> some View {
        let theme = themeManager.current

        return VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(theme.colors.textTertiary)

            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(theme.colors.textTertiary)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.sm)
    }

    private var notesStatCell: some View {
        let theme = themeManager.current

        return VStack(spacing: 4) {
            Text("NOTES")
                .font(.caption2.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(theme.colors.textTertiary)

            if hasNotes {
                Button {
                    onNotesReadTap?()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(theme.colors.accent)

                        Text("Read")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.colors.accent)
                    }
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "minus")
                        .font(.caption)
                        .foregroundStyle(theme.colors.textTertiary)

                    Text("None")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.sm)
    }

    // MARK: - Helpers

    private var formattedVolume: String {
        let converted = volume.formatWeight(unit: settings.liftingUnit, decimals: 0)
        // Remove the unit suffix since we display it separately
        return converted.replacingOccurrences(of: " \(settings.liftingUnit.abbreviation)", with: "")
            .replacingOccurrences(of: settings.liftingUnit.abbreviation, with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    private var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Preview

#Preview("WorkoutDetailStatsCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack {
            WorkoutDetailStatsCard(
                volume: 12450,
                setCount: 18,
                prCount: 3,
                exerciseCount: 6,
                duration: 4500,
                hasNotes: true,
                onNotesReadTap: { print("Notes tapped") }
            )
            .padding()

            WorkoutDetailStatsCard(
                volume: 8500,
                setCount: 12,
                prCount: 0,
                exerciseCount: 4,
                duration: 2700,
                hasNotes: false
            )
            .padding()

            Spacer()
        }
    }
    .environment(ThemeManager())
}
