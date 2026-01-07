import SwiftUI

/// Centralized metrics for all tab root headers (AppTabHeader + DashboardHeaderView).
/// Ensures consistent spacing, sizing, and tap targets across all tab root screens.
enum HeaderMetrics {
    // MARK: - Fixed Values (don't scale - tap targets must stay 44pt minimum)

    /// Minimum tap target size per Apple HIG
    static let buttonTapSize: CGFloat = 44

    /// Visual button size (smaller than tap target)
    static let buttonVisualSize: CGFloat = 40

    /// Icon size inside buttons
    static let iconSize: CGFloat = 16

    /// Horizontal padding from screen edges
    static let horizontalPadding: CGFloat = 16

    /// Spacing between action buttons
    static let buttonSpacing: CGFloat = 4

    // MARK: - Base Values for @ScaledMetric (scale with Dynamic Type)

    /// Base vertical padding (top and bottom of header)
    static let baseVerticalPadding: CGFloat = 12

    /// Base spacing between title and subtitle
    static let baseTitleSubtitleSpacing: CGFloat = 2

    /// Base spacing between title area and trailing buttons
    static let baseTitleButtonSpacing: CGFloat = 8
}
