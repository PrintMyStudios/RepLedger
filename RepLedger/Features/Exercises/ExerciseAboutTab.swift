import SwiftUI

/// About tab showing exercise metadata: muscle group, equipment, notes.
struct ExerciseAboutTab: View {
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise

    var body: some View {
        let theme = themeManager.current

        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                // Muscle group
                InfoRow(
                    label: "Muscle Group",
                    value: exercise.muscleGroup.displayName,
                    icon: exercise.muscleGroup.icon
                )

                // Equipment
                InfoRow(
                    label: "Equipment",
                    value: exercise.equipment.displayName,
                    icon: equipmentIcon
                )

                // Notes (if any)
                if !exercise.notes.isEmpty {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text("Notes")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)

                        Text(exercise.notes)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.text)
                    }
                    .padding(theme.spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
                }

                Spacer()
            }
            .padding(theme.spacing.md)
        }
    }

    private var equipmentIcon: String {
        switch exercise.equipment {
        case .barbell: return "figure.strengthtraining.traditional"
        case .dumbbell: return "dumbbell.fill"
        case .cable: return "arrow.left.arrow.right"
        case .machine: return "gearshape.fill"
        case .bodyweight: return "figure.stand"
        case .kettlebell: return "figure.strengthtraining.functional"
        case .bands: return "link"
        case .other: return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let label: String
    let value: String
    let icon: String

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(theme.colors.accent)
                .frame(width: 40, height: 40)
                .background(theme.colors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)

                Text(value)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)
            }

            Spacer()
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - Preview

#Preview("ExerciseAboutTab") {
    ExerciseAboutTab(
        exercise: Exercise.seeded(
            name: "Barbell Bench Press",
            muscleGroup: .chest,
            equipment: .barbell,
            notes: "Keep your shoulder blades retracted and maintain a slight arch in your lower back."
        )
    )
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
