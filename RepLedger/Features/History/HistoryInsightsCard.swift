import SwiftUI

/// Compact insights card showing weekly stats with improved typography.
/// Replaces the previous separate stats pills with a unified design.
struct HistoryInsightsCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let stats: HistoryWeeklyStats
    let isThisWeekSelected: Bool
    let onThisWeekTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onThisWeekTap) {
            HStack(spacing: 0) {
                // Sessions column
                metricColumn(
                    label: "Sessions",
                    value: stats.sessionsText,
                    sublabel: "this week",
                    showAccent: isThisWeekSelected
                )

                // Divider
                Rectangle()
                    .fill(theme.colors.divider)
                    .frame(width: 1)
                    .padding(.vertical, 8)

                // Volume column
                metricColumn(
                    label: "Volume",
                    value: stats.volumeText,
                    badge: stats.trendText,
                    badgePositive: stats.trendIsPositive
                )

                // Divider
                Rectangle()
                    .fill(theme.colors.divider)
                    .frame(width: 1)
                    .padding(.vertical, 8)

                // Time column
                metricColumn(
                    label: "Time",
                    value: stats.timeText,
                    sublabel: "training"
                )
            }
            .padding(.vertical, 14)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(
                        isThisWeekSelected ? theme.colors.accent.opacity(0.5) : theme.colors.border,
                        lineWidth: isThisWeekSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isThisWeekSelected ? "Showing this week only. Tap to show all." : "Tap to filter to this week only.")
    }

    // MARK: - Metric Column

    private func metricColumn(
        label: String,
        value: String,
        sublabel: String? = nil,
        badge: String? = nil,
        badgePositive: Bool = true,
        showAccent: Bool = false
    ) -> some View {
        let theme = themeManager.current

        return VStack(spacing: 4) {
            // Label
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.5)
                .foregroundStyle(showAccent ? theme.colors.accent : theme.colors.textTertiary)

            // Value row
            HStack(spacing: 4) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(theme.colors.text)

                // Optional badge
                if let badge = badge {
                    Text(badge)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(badgePositive ? theme.colors.accent : theme.colors.error)
                }
            }

            // Sublabel
            if let sublabel = sublabel {
                Text(sublabel)
                    .font(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var accessibilityLabel: String {
        var parts = [
            "\(stats.sessionsCompleted) of \(stats.sessionsGoal) sessions this week",
            "\(stats.volumeText) volume, \(stats.trendText) versus last week",
            "\(stats.timeText) training time"
        ]
        return parts.joined(separator: ". ")
    }
}

// MARK: - Preview

#Preview("HistoryInsightsCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack(spacing: 20) {
            HistoryInsightsCard(
                stats: .mock,
                isThisWeekSelected: false,
                onThisWeekTap: {}
            )

            HistoryInsightsCard(
                stats: .mock,
                isThisWeekSelected: true,
                onThisWeekTap: {}
            )
        }
        .padding()
    }
    .environment(ThemeManager())
}
