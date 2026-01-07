import SwiftUI

/// Records tab showing personal records for the exercise.
struct ExerciseRecordsTab: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let exercise: Exercise
    let personalRecords: [PRType: PersonalRecord]

    var body: some View {
        let theme = themeManager.current

        Group {
            if personalRecords.isEmpty {
                RLEmptyState.noPRs()
            } else {
                ScrollView {
                    VStack(spacing: theme.spacing.md) {
                        // Max Weight PR
                        if let pr = personalRecords[.maxWeight] {
                            PRCard(
                                title: PRType.maxWeight.titleText,
                                value: pr.value.formatWeight(unit: settings.liftingUnit, decimals: 1),
                                subtitle: formatDate(pr.achievedAt),
                                icon: PRType.maxWeight.icon
                            )
                        }

                        // Max e1RM PR
                        if let pr = personalRecords[.maxE1RM] {
                            PRCard(
                                title: PRType.maxE1RM.titleText,
                                value: pr.value.formatWeight(unit: settings.liftingUnit, decimals: 1),
                                subtitle: formatDate(pr.achievedAt),
                                icon: PRType.maxE1RM.icon
                            )
                        }

                        // Max Volume PR
                        if let pr = personalRecords[.maxVolume] {
                            PRCard(
                                title: PRType.maxVolume.titleText,
                                value: pr.value.formatWeight(unit: settings.liftingUnit, decimals: 0),
                                subtitle: formatDate(pr.achievedAt),
                                icon: PRType.maxVolume.icon
                            )
                        }
                    }
                    .padding(theme.spacing.md)
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Set on \(formatter.string(from: date))"
    }
}

// MARK: - PR Card

private struct PRCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            // Icon
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(theme.colors.warning)
                .frame(width: 56, height: 56)
                .background(theme.colors.warning.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                Text(value)
                    .font(theme.typography.titleMedium)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.text)

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }

            Spacer()

            // Trophy badge
            Image(systemName: "trophy.fill")
                .font(.title2)
                .foregroundStyle(theme.colors.warning)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - Preview

#Preview("ExerciseRecordsTab") {
    ExerciseRecordsTab(
        exercise: Exercise.seeded(name: "Barbell Bench Press", muscleGroup: .chest, equipment: .barbell),
        personalRecords: [
            .maxWeight: PersonalRecord(
                type: .maxWeight,
                value: 100,
                setId: UUID(),
                workoutId: UUID(),
                achievedAt: Date().addingTimeInterval(-86400 * 7)
            ),
            .maxE1RM: PersonalRecord(
                type: .maxE1RM,
                value: 120,
                setId: UUID(),
                workoutId: UUID(),
                achievedAt: Date().addingTimeInterval(-86400 * 3)
            ),
            .maxVolume: PersonalRecord(
                type: .maxVolume,
                value: 800,
                setId: UUID(),
                workoutId: UUID(),
                achievedAt: Date()
            )
        ]
    )
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
