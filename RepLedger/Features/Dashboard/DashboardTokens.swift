import SwiftUI

/// Centralized dashboard layout and typography tokens.
/// Spacing uses CGFloat for exact control.
/// Typography uses Font for Dynamic Type support.
enum DashboardTokens {
    // MARK: - Layout (CGFloat)

    /// Horizontal padding from screen edges (20pt)
    static let horizontalGutter: CGFloat = 20

    /// Spacing between major sections/cards (16pt)
    static let sectionSpacing: CGFloat = 16

    /// Spacing between small cards in HStack (12pt)
    static let cardSpacing: CGFloat = 12

    /// Internal padding within cards (16pt)
    static let cardPadding: CGFloat = 16

    /// Card corner radius (18pt)
    static let cornerRadius: CGFloat = 18

    // MARK: - Typography (Font - supports Dynamic Type)

    /// Section labels like "THIS WEEK", "LATEST WORKOUT" (12pt semibold)
    static let sectionLabel: Font = .system(size: 12, weight: .semibold)

    /// Card titles (16pt semibold)
    static let cardTitle: Font = .system(size: 16, weight: .semibold)

    /// Secondary text like time ago, subtitles (14pt medium)
    static let secondaryText: Font = .system(size: 14, weight: .medium)

    /// Trend text and status labels (13pt medium)
    static let trendText: Font = .system(size: 13, weight: .medium)

    // Note: Primary metrics (large numbers like "80 kg") should use
    // @ScaledMetric in views for accessibility scaling:
    //
    // @ScaledMetric(relativeTo: .largeTitle) private var metricSize: CGFloat = 38
    //
    // Text(value)
    //     .font(.system(size: metricSize, weight: .bold, design: .rounded))
    //     .lineLimit(1)
    //     .minimumScaleFactor(0.75)

    // MARK: - Card border

    /// Border opacity for subtle card edges (0.5)
    static let cardBorderOpacity: Double = 0.5
}
