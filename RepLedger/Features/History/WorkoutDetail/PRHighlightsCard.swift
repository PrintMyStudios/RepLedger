import SwiftUI

/// PR Highlights card showing personal records achieved in a workout
struct PRHighlightsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let prs: [WorkoutSetPR]

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(theme.colors.accentGold)

                    Text("PR HIGHLIGHTS")
                        .font(.caption.weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(theme.colors.accentGold)
                }

                Spacer()

                if prs.count > 3 {
                    Text("View all")
                        .font(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            // PR list
            VStack(spacing: theme.spacing.sm) {
                ForEach(Array(prs.prefix(5).enumerated()), id: \.element.id) { _, pr in
                    prRow(pr)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            // Subtle gold gradient background
            LinearGradient(
                colors: [
                    theme.colors.accentGold.opacity(0.08),
                    theme.colors.surface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(theme.colors.accentGold.opacity(0.2), lineWidth: 1)
        }
        // Trophy watermark
        .overlay(alignment: .topTrailing) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(theme.colors.accentGold.opacity(0.05))
                .offset(x: -theme.spacing.md, y: theme.spacing.md)
        }
        .clipped()
    }

    // MARK: - PR Row

    private func prRow(_ pr: WorkoutSetPR) -> some View {
        let theme = themeManager.current

        return HStack(alignment: .top, spacing: theme.spacing.sm) {
            // Gold bullet
            Circle()
                .fill(theme.colors.accentGold)
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(pr.exerciseName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.colors.text)
                        .lineLimit(1)

                    Spacer()

                    prBadge(for: pr.prType)
                }

                Text(prValueText(pr))
                    .font(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
    }

    private func prBadge(for prType: PRType) -> some View {
        let theme = themeManager.current
        let color = prType == .maxVolume ? theme.colors.accentOrange : theme.colors.accentGold

        return Text(prType.badgeText)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.3), lineWidth: 0.5)
            }
    }

    private func prValueText(_ pr: WorkoutSetPR) -> String {
        switch pr.prType {
        case .maxWeight:
            if let weight = pr.weight, let reps = pr.reps {
                let weightStr = weight.formatWeight(unit: settings.liftingUnit, decimals: 1)
                return "\(weightStr) × \(reps)"
            }
            return pr.value.formatWeight(unit: settings.liftingUnit, decimals: 1)

        case .maxE1RM:
            // Show the calculated e1RM value, not weight × reps
            return "e1RM: \(pr.value.formatWeight(unit: settings.liftingUnit, decimals: 1))"

        case .maxVolume:
            let volumeStr = pr.value.formatWeight(unit: settings.liftingUnit, decimals: 0)
            return "Vol: \(volumeStr)"
        }
    }
}

// MARK: - Preview

#Preview("PRHighlightsCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack {
            PRHighlightsCard(prs: [
                WorkoutSetPR(
                    exerciseId: UUID(),
                    exerciseName: "Bench Press",
                    setId: UUID(),
                    prType: .maxWeight,
                    value: 102.5,
                    previousBest: 100,
                    weight: 102.5,
                    reps: 5
                ),
                WorkoutSetPR(
                    exerciseId: UUID(),
                    exerciseName: "Incline DB Press",
                    setId: UUID(),
                    prType: .maxVolume,
                    value: 960,
                    previousBest: 900,
                    weight: 32,
                    reps: 8
                ),
                WorkoutSetPR(
                    exerciseId: UUID(),
                    exerciseName: "Overhead Press",
                    setId: UUID(),
                    prType: .maxE1RM,
                    value: 75,
                    previousBest: 72,
                    weight: 60,
                    reps: 8
                )
            ])
            .padding()

            Spacer()
        }
    }
    .environment(ThemeManager())
}
