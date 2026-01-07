import SwiftUI

struct LatestPRCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let latestPR: LatestPRData?
    let isLoading: Bool

    // MARK: - Computed Properties

    private var exerciseName: String {
        latestPR?.exerciseName ?? "—"
    }

    private var weightText: String {
        guard let pr = latestPR else { return "—" }
        let converted = pr.weight.fromKg(to: settings.liftingUnit)
        return String(format: "%.0f", converted)
    }

    private var unitText: String {
        settings.liftingUnit.abbreviation
    }

    private var prTypeText: String {
        guard let pr = latestPR else { return "" }
        switch pr.prType {
        case .maxWeight: return "Max Load"
        case .maxE1RM: return "Est. 1RM"
        case .maxVolume: return "Max Set Vol"
        }
    }

    private var prContextText: String {
        guard let pr = latestPR else { return "" }
        return "\(prTypeText) • \(pr.timeAgoText)"
    }

    var body: some View {
        let theme = themeManager.current

        SmallDashboardCard {
            ZStack {
                // Background glow effect (only show if we have a PR)
                if latestPR != nil && !isLoading {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.colors.accentGold.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                }

                // Content
                if isLoading {
                    loadingContent(theme: theme)
                } else if latestPR == nil {
                    noPRContent(theme: theme)
                } else {
                    prContent(theme: theme)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(latestPR != nil ? "Latest personal record: \(exerciseName), \(weightText) \(unitText)" : "No personal records yet")
    }

    // MARK: - Content States

    @ViewBuilder
    private func loadingContent(theme: any Theme) -> some View {
        VStack(spacing: 0) {
            // Header - top
            HStack(spacing: 5) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.colors.accentGold)

                Text("LATEST PR")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(theme.colors.accentGold)
            }

            Spacer()

            // Weight placeholder
            Text("000")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(theme.colors.text)
                .redacted(reason: .placeholder)

            Spacer()

            // Exercise name placeholder
            Text("Loading...")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.colors.textSecondary)
                .redacted(reason: .placeholder)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func noPRContent(theme: any Theme) -> some View {
        VStack(spacing: 8) {
            // Header
            HStack(spacing: 5) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.colors.textTertiary)

                Text("LATEST PR")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(theme.colors.textTertiary)
            }

            Spacer()

            // Empty state
            VStack(spacing: 4) {
                Image(systemName: "trophy")
                    .font(.system(size: 28))
                    .foregroundStyle(theme.colors.textTertiary)

                Text("No PRs yet")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func prContent(theme: any Theme) -> some View {
        VStack(spacing: 0) {
            // Header - top
            HStack(spacing: 5) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.colors.accentGold)

                Text("LATEST PR")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(theme.colors.accentGold)
            }

            Spacer()

            // Weight - center, large and prominent
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(weightText)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.colors.text)

                Text(unitText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.colors.textTertiary)
            }

            Spacer()

            // Exercise name + context - bottom
            VStack(spacing: 2) {
                Text(exerciseName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)

                // Context line (PR type + time ago)
                if !prContextText.isEmpty {
                    Text(prContextText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Real data
                LatestPRCard(
                    latestPR: LatestPRData(
                        id: UUID(),
                        exerciseName: "Bench Press",
                        prType: .maxWeight,
                        weight: 102.5,
                        reps: 5,
                        achievedAt: Date()
                    ),
                    isLoading: false
                )

                // No PRs
                LatestPRCard(
                    latestPR: nil,
                    isLoading: false
                )
            }

            HStack(spacing: 12) {
                // Loading
                LatestPRCard(
                    latestPR: nil,
                    isLoading: true
                )

                RecoveryCard(
                    recovery: [
                        RecoveryItem(muscle: .chest, recovered: 0.35, hoursSinceTraining: 12)
                    ],
                    isLoading: false
                )
            }
        }
        .padding()
    }
    .environment(ThemeManager())
}
