import SwiftUI

/// Weekly stats data for the stats pills
struct HistoryWeeklyStats {
    let sessionsCompleted: Int
    let sessionsGoal: Int
    let totalVolume: Double
    let volumeTrend: Double  // Percentage change vs last week
    let totalTime: TimeInterval

    // MARK: - Formatted Values

    var sessionsText: String {
        "\(sessionsCompleted)/\(sessionsGoal)"
    }

    var volumeText: String {
        let volumeK = totalVolume / 1000
        if volumeK >= 100 {
            return String(format: "%.0fk", volumeK)
        } else if volumeK >= 10 {
            return String(format: "%.1fk", volumeK)
        } else if volumeK >= 1 {
            return String(format: "%.1fk", volumeK)
        } else {
            return String(format: "%.0f", totalVolume)
        }
    }

    var trendText: String {
        let sign = volumeTrend >= 0 ? "+" : ""
        return "\(sign)\(Int(volumeTrend))%"
    }

    var trendIsPositive: Bool {
        volumeTrend >= 0
    }

    var timeText: String {
        let hours = Int(totalTime) / 3600
        let minutes = (Int(totalTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Empty/Default Data

    /// Empty stats used as initial state before real data loads
    static let empty = HistoryWeeklyStats(
        sessionsCompleted: 0,
        sessionsGoal: 4,
        totalVolume: 0,
        volumeTrend: 0,
        totalTime: 0
    )

    // MARK: - Mock Data (Preview Only)

    static let mock = HistoryWeeklyStats(
        sessionsCompleted: 3,
        sessionsGoal: 4,
        totalVolume: 45200,
        volumeTrend: 12,
        totalTime: 15120  // 4h 12m
    )
}

/// Horizontal scrolling stats pills for history header
struct HistoryStatsPillsView: View {
    @Environment(ThemeManager.self) private var themeManager

    let stats: HistoryWeeklyStats
    let isThisWeekSelected: Bool
    let onThisWeekTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.spacing.sm) {
                // This Week pill (tappable, highlighted when selected)
                thisWeekPill

                // Volume pill
                volumePill

                // Time pill
                timePill
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    // MARK: - This Week Pill

    private var thisWeekPill: some View {
        let theme = themeManager.current

        return Button(action: onThisWeekTap) {
            VStack(alignment: .leading, spacing: 2) {
                Text("This Week")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(isThisWeekSelected ? theme.colors.accent : theme.colors.textSecondary)

                Text(stats.sessionsText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.colors.text)

                Text("Sessions")
                    .font(.system(size: 9))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(
                        isThisWeekSelected ? theme.colors.accent : theme.colors.border,
                        lineWidth: isThisWeekSelected ? 2 : 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("This week, \(stats.sessionsCompleted) of \(stats.sessionsGoal) sessions")
    }

    // MARK: - Volume Pill

    private var volumePill: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: 2) {
            Text("Volume")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(stats.volumeText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(theme.colors.text)

                Text(stats.trendText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(stats.trendIsPositive ? theme.colors.accent : theme.colors.error)
            }

            Text("kg lifted")
                .font(.system(size: 9))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .stroke(theme.colors.border, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Volume, \(stats.volumeText) kilograms, \(stats.trendText) versus last week")
    }

    // MARK: - Time Pill

    private var timePill: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: 2) {
            Text("Time")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)

            Text(stats.timeText)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(theme.colors.text)

            Text("training")
                .font(.system(size: 9))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .stroke(theme.colors.border, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Time, \(stats.timeText) training this week")
    }
}

// MARK: - Preview

#Preview("HistoryStatsPillsView") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack {
            HistoryStatsPillsView(
                stats: .mock,
                isThisWeekSelected: true,
                onThisWeekTap: {}
            )
            Spacer()
        }
        .padding(.top, 20)
    }
    .environment(ThemeManager())
}
