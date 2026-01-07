import SwiftUI

struct DashboardStatsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    /// Scaled metric for Dynamic Type support on primary metric
    @ScaledMetric(relativeTo: .largeTitle) private var metricSize: CGFloat = 38

    let stats: DashboardStats?
    let weeklyVolumeByDay: [Double]
    let isLoading: Bool

    // MARK: - Computed Properties

    private var volumeText: String {
        guard let stats = stats else { return "—" }
        let converted = stats.weeklyVolume.fromKg(to: settings.liftingUnit)
        if converted >= 10000 {
            return String(format: "%.0fk", converted / 1000)
        } else if converted >= 1000 {
            return String(format: "%.1fk", converted / 1000).replacingOccurrences(of: ".0k", with: "k")
        }
        return String(format: "%.0f", converted)
    }

    private var unitText: String {
        settings.liftingUnit.abbreviation
    }

    /// Full trend text with appropriate suffix based on trend type
    /// Rules:
    /// - percentage: "+12% vs last week" or "-8% vs last week"
    /// - new (lastWeek=0, thisWeek>0): "New vs last week"
    /// - none (both weeks=0): "—" (no suffix)
    private var fullTrendText: String {
        guard let stats = stats else { return "—" }
        switch stats.volumeTrend {
        case .percentage:
            return "\(stats.volumeTrend.text) vs last week"
        case .new:
            return "New vs last week"
        case .none:
            return "—"
        }
    }

    private var trendIsPositive: Bool {
        stats?.volumeTrend.isPositive ?? false
    }

    /// Whether to show trend text (hide when it's just "—")
    private var shouldShowTrend: Bool {
        guard let stats = stats else { return false }
        if case .none = stats.volumeTrend { return false }
        return true
    }

    /// Normalize volume data to 0-1 range for chart
    private var normalizedVolume: [Double] {
        guard let maxValue = weeklyVolumeByDay.max(), maxValue > 0 else {
            return weeklyVolumeByDay.isEmpty ? [0, 0, 0, 0, 0, 0, 0] : weeklyVolumeByDay
        }
        return weeklyVolumeByDay.map { $0 / maxValue }
    }

    /// Index of the day with max volume (for highlighting)
    private var highlightIndex: Int {
        guard let maxValue = weeklyVolumeByDay.max(), maxValue > 0 else { return -1 }
        return weeklyVolumeByDay.firstIndex(of: maxValue) ?? -1
    }

    private var goalCurrent: Int {
        stats?.sessionsCompleted ?? 0
    }

    private var goalTarget: Int {
        stats?.sessionsGoal ?? 4
    }

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: 10) {
            // "THIS WEEK" label at top
            Text("THIS WEEK")
                .font(DashboardTokens.sectionLabel)
                .tracking(1.0)
                .foregroundStyle(theme.colors.textTertiary)

            // Two columns with spacing (no divider)
            HStack(alignment: .top, spacing: 24) {
                // Left: Weekly Volume
                leftSection(theme: theme)

                // Right: Goal Progress
                rightSection(theme: theme)
            }
            .frame(height: 140) // Fixed height for consistent card sizing
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

    // MARK: - Left Section (Weekly Volume)

    @ViewBuilder
    private func leftSection(theme: any Theme) -> some View {
        VStack(spacing: 0) {
            // Header label (sentence case, not shouting)
            Text("Volume")
                .font(DashboardTokens.secondaryText)
                .foregroundStyle(theme.colors.textTertiary)

            Spacer(minLength: 8)

            // Volume number + unit with proper baseline alignment
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(volumeText)
                    .font(.system(size: metricSize, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(unitText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .redacted(reason: isLoading ? .placeholder : [])

            // Trend indicator (only show if meaningful)
            if shouldShowTrend || isLoading {
                Text(fullTrendText)
                    .font(DashboardTokens.trendText)
                    .foregroundStyle(trendIsPositive ? theme.colors.accent : theme.colors.error)
                    .padding(.top, 2)
                    .redacted(reason: isLoading ? .placeholder : [])
            }

            Spacer(minLength: 12)

            // Mini chart - at bottom (7-day Mon–Sun sparkline)
            WeeklyVolumeChart(
                data: normalizedVolume,
                highlightIndex: highlightIndex
            )
            .redacted(reason: isLoading ? .placeholder : [])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Right Section (Goal Progress)

    @ViewBuilder
    private func rightSection(theme: any Theme) -> some View {
        VStack(spacing: 0) {
            // Header label (sentence case, matching left section)
            Text("Workouts")
                .font(DashboardTokens.secondaryText)
                .foregroundStyle(theme.colors.textTertiary)

            Spacer(minLength: 8)

            // Progress ring - centered
            GoalProgressRing(
                current: goalCurrent,
                target: goalTarget,
                size: 68
            )
            .redacted(reason: isLoading ? .placeholder : [])

            Spacer(minLength: 12)

            // Status text (subtle, no badge)
            statusText(theme: theme)
                .redacted(reason: isLoading ? .placeholder : [])
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func statusText(theme: any Theme) -> some View {
        let (text, color) = goalStatus(theme: theme)

        Text(text)
            .font(DashboardTokens.trendText)
            .foregroundStyle(color)
    }

    private func goalStatus(theme: any Theme) -> (String, Color) {
        guard goalTarget > 0 else { return ("—", theme.colors.textTertiary) }

        if goalCurrent >= goalTarget {
            return ("Complete", theme.colors.accent)
        }

        // Deterministic pace logic:
        // expectedByToday = ceil(goal * progressThroughWeek)
        // where progressThroughWeek = dayOfWeek / 7 (Mon=1, Sun=7)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let dayOfWeek = weekday == 1 ? 7 : weekday - 1 // Mon=1, Sun=7
        let progressThroughWeek = Double(dayOfWeek) / 7.0
        let expectedByToday = Int(ceil(Double(goalTarget) * progressThroughWeek))
        let delta = goalCurrent - expectedByToday

        if delta >= 1 {
            return ("Ahead", theme.colors.accent)
        } else if delta == 0 {
            return ("On track", theme.colors.accent)
        } else {
            let behind = abs(delta)
            return ("\(behind) behind pace", theme.colors.textSecondary)
        }
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        ScrollView {
            VStack(spacing: 16) {
                // Real data with positive trend
                DashboardStatsCard(
                    stats: DashboardStats(
                        weeklyVolume: 45200,
                        volumeTrend: .percentage(12),
                        sessionsCompleted: 3,
                        sessionsGoal: 4
                    ),
                    weeklyVolumeByDay: [3000, 0, 5200, 0, 8000, 12000, 0],
                    isLoading: false
                )

                // New vs last week (first week)
                DashboardStatsCard(
                    stats: DashboardStats(
                        weeklyVolume: 8500,
                        volumeTrend: .new,
                        sessionsCompleted: 1,
                        sessionsGoal: 4
                    ),
                    weeklyVolumeByDay: [0, 8500, 0, 0, 0, 0, 0],
                    isLoading: false
                )

                // Negative trend
                DashboardStatsCard(
                    stats: DashboardStats(
                        weeklyVolume: 32000,
                        volumeTrend: .percentage(-15),
                        sessionsCompleted: 2,
                        sessionsGoal: 4
                    ),
                    weeklyVolumeByDay: [10000, 0, 22000, 0, 0, 0, 0],
                    isLoading: false
                )

                // Loading state
                DashboardStatsCard(
                    stats: nil,
                    weeklyVolumeByDay: [],
                    isLoading: true
                )
            }
            .padding()
        }
    }
    .environment(ThemeManager())
}
