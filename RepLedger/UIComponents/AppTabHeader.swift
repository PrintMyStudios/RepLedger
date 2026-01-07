import SwiftUI

/// Reusable header for tab root screens (Start, History, Exercises, Settings).
/// Provides consistent left-aligned title with optional subtitle and trailing action buttons.
///
/// Usage:
/// ```swift
/// .safeAreaInset(edge: .top, spacing: 0) {
///     AppTabHeader(title: "History", subtitle: "42 workouts") {
///         HeaderActionButton(icon: "magnifyingglass", action: { })
///     }
/// }
/// ```
struct AppTabHeader<TrailingContent: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    // Scaled metrics for Dynamic Type support
    @ScaledMetric(relativeTo: .body) private var verticalPadding = HeaderMetrics.baseVerticalPadding
    @ScaledMetric(relativeTo: .body) private var titleSubtitleSpacing = HeaderMetrics.baseTitleSubtitleSpacing

    let title: String
    let subtitle: String?
    @ViewBuilder let trailingContent: () -> TrailingContent

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingContent = trailingContent
    }

    var body: some View {
        let theme = themeManager.current

        HStack(alignment: .top, spacing: HeaderMetrics.baseTitleButtonSpacing) {
            // Title + Subtitle (left-aligned)
            VStack(alignment: .leading, spacing: titleSubtitleSpacing) {
                Text(title)
                    .font(.system(size: 26, weight: .bold))  // 26pt bold
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer(minLength: 8)

            // Trailing actions (aligned to top/title row)
            HStack(spacing: HeaderMetrics.buttonSpacing) {
                trailingContent()
            }
        }
        .padding(.horizontal, HeaderMetrics.horizontalPadding)
        .padding(.vertical, verticalPadding)
        // CRITICAL: Extend background into safe area (status bar/notch)
        .background(theme.colors.background, ignoresSafeAreaEdges: .top)
    }
}

// MARK: - Previews

#Preview("AppTabHeader - Simple") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack {
            AppTabHeader(title: "Settings")

            Spacer()
        }
    }
    .environment(ThemeManager())
}

#Preview("AppTabHeader - With Subtitle") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack {
            AppTabHeader(
                title: "History",
                subtitle: "42 workouts completed"
            ) {
                HeaderActionButton(icon: "magnifyingglass", action: {})
                HeaderActionButton(icon: "line.3.horizontal.decrease", action: {}, badge: .activeFilter)
            }

            Spacer()
        }
    }
    .environment(ThemeManager())
}

#Preview("AppTabHeader - Long Title") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack {
            AppTabHeader(
                title: "Very Long Title That Might Need Two Lines",
                subtitle: "Subtitle text here"
            ) {
                HeaderActionButton(icon: "magnifyingglass", action: {})
            }

            Spacer()
        }
    }
    .environment(ThemeManager())
}
