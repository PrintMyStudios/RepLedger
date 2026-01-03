import SwiftUI

/// A tile displaying a statistic value with a label.
/// Used for dashboard stats, workout summaries, exercise records, etc.
struct RLStatTile: View {
    @Environment(ThemeManager.self) private var themeManager

    let value: String
    let label: String
    let icon: String?
    let trend: Trend?
    let size: TileSize

    enum TileSize {
        case compact   // Inline stats
        case standard  // Dashboard tiles
        case large     // Featured stats

        var valueFont: Font {
            switch self {
            case .compact: return .title3.weight(.bold)
            case .standard: return .title2.weight(.bold)
            case .large: return .largeTitle.weight(.bold)
            }
        }

        var labelFont: Font {
            switch self {
            case .compact: return .caption
            case .standard: return .subheadline
            case .large: return .body
            }
        }
    }

    enum Trend {
        case up(String)    // e.g., "+5%"
        case down(String)  // e.g., "-3%"
        case neutral(String)

        var color: (any Theme) -> Color {
            switch self {
            case .up: return { $0.colors.success }
            case .down: return { $0.colors.error }
            case .neutral: return { $0.colors.textSecondary }
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .neutral: return "minus"
            }
        }

        var text: String {
            switch self {
            case .up(let value), .down(let value), .neutral(let value):
                return value
            }
        }
    }

    init(
        value: String,
        label: String,
        icon: String? = nil,
        trend: Trend? = nil,
        size: TileSize = .standard
    ) {
        self.value = value
        self.label = label
        self.icon = icon
        self.trend = trend
        self.size = size
    }

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Icon and label row
            HStack(spacing: theme.spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.labelFont)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Text(label)
                    .font(size.labelFont)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            // Value row with optional trend
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(value)
                    .font(size.valueFont)
                    .foregroundStyle(theme.colors.text)
                    .monospacedDigit()

                if let trend = trend {
                    HStack(spacing: 2) {
                        Image(systemName: trend.icon)
                            .font(.caption2.weight(.bold))
                        Text(trend.text)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundStyle(trend.color(theme))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Grid Layout Helper

struct RLStatGrid<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let columns: Int
    let content: () -> Content

    init(columns: Int = 2, @ViewBuilder content: @escaping () -> Content) {
        self.columns = columns
        self.content = content
    }

    var body: some View {
        let theme = themeManager.current

        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: theme.spacing.md), count: columns),
            spacing: theme.spacing.md
        ) {
            content()
        }
    }
}

// MARK: - Convenience Initializers

extension RLStatTile {
    /// Creates a volume stat tile
    static func volume(_ value: String, trend: Trend? = nil) -> RLStatTile {
        RLStatTile(
            value: value,
            label: "Total Volume",
            icon: "scalemass.fill",
            trend: trend
        )
    }

    /// Creates a workout count tile
    static func workouts(_ count: Int) -> RLStatTile {
        RLStatTile(
            value: "\(count)",
            label: "Workouts",
            icon: "figure.strengthtraining.traditional"
        )
    }

    /// Creates a duration tile
    static func duration(_ value: String) -> RLStatTile {
        RLStatTile(
            value: value,
            label: "Duration",
            icon: "clock.fill"
        )
    }

    /// Creates a PR count tile
    static func prs(_ count: Int) -> RLStatTile {
        RLStatTile(
            value: "\(count)",
            label: "Personal Records",
            icon: "trophy.fill"
        )
    }
}

// MARK: - Preview

#Preview("RLStatTile") {
    VStack(spacing: 24) {
        // Standard tiles
        RLCard {
            RLStatGrid {
                RLStatTile.volume("12,450 kg", trend: .up("+8%"))
                RLStatTile.workouts(24)
                RLStatTile.duration("1h 15m")
                RLStatTile.prs(3)
            }
        }

        // Compact inline
        HStack(spacing: 24) {
            RLStatTile(value: "80", label: "kg", size: .compact)
            RLStatTile(value: "8", label: "reps", size: .compact)
            RLStatTile(value: "3", label: "sets", size: .compact)
        }
        .padding()
        .background(Color(hex: "141416"))
        .clipShape(RoundedRectangle(cornerRadius: 12))

        // Large featured
        RLStatTile(
            value: "142.5 kg",
            label: "1RM Squat",
            icon: "trophy.fill",
            trend: .up("+5 kg"),
            size: .large
        )
    }
    .padding()
    .background(Color(hex: "0A0A0C"))
    .environment(ThemeManager())
}
