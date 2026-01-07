import SwiftUI

/// 7-day sparkline chart (Mon–Sun) for weekly volume visualization.
/// Always shows exactly 7 bars regardless of input data.
struct WeeklyVolumeChart: View {
    @Environment(ThemeManager.self) private var themeManager

    /// Volume data for 7 days (Mon–Sun). Padded or truncated to exactly 7 entries.
    let data: [Double]
    /// Index of the bar to highlight (typically max volume day). Use -1 for no highlight.
    let highlightIndex: Int

    // Chart configuration
    private let chartHeight: CGFloat = 48
    private let barWidth: CGFloat = 10
    private let barSpacing: CGFloat = 4
    private let barCornerRadius: CGFloat = 3
    private let minBarHeight: CGFloat = 8  // Increased from 6 to ensure visibility

    /// Ensures exactly 7 data points (Mon–Sun)
    private var normalizedData: [Double] {
        var result = data
        // Pad with zeros if fewer than 7
        while result.count < 7 {
            result.append(0)
        }
        // Truncate if more than 7
        return Array(result.prefix(7))
    }

    var body: some View {
        let theme = themeManager.current
        let chartData = normalizedData
        let maxValue = chartData.max() ?? 1

        HStack(alignment: .bottom, spacing: barSpacing) {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                let normalizedHeight = maxValue > 0 ? value / maxValue : 0
                let isHighlighted = index == highlightIndex
                let hasValue = value > 0
                let barHeight = max(minBarHeight, chartHeight * normalizedHeight)

                // Zero bars use 0.5 opacity for clear visibility as chart elements
                let barFill: Color = isHighlighted ? theme.colors.accent :
                    hasValue ? theme.colors.elevated : theme.colors.elevated.opacity(0.5)

                RoundedRectangle(cornerRadius: barCornerRadius)
                    .fill(barFill)
                    .frame(width: barWidth, height: barHeight)
                    .rlShadow(isHighlighted ? theme.shadows.neonGlow : RLShadow(color: .clear, radius: 0, x: 0, y: 0))
            }
        }
        .frame(height: chartHeight)
    }
}

#Preview("Weekly Chart") {
    let theme = ObsidianTheme()
    ZStack {
        theme.colors.background.ignoresSafeArea()
        VStack(spacing: 32) {
            WeeklyVolumeChart(
                data: [0.3, 0.4, 0.25, 0.6, 0.45, 0.8, 0.2],
                highlightIndex: 5
            )

            // In context
            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly Volume")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                WeeklyVolumeChart(
                    data: [0.3, 0.4, 0.25, 0.6, 0.45, 0.8, 0.2],
                    highlightIndex: 5
                )
            }
            .padding()
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
    .environment(ThemeManager())
}
