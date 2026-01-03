import SwiftUI

/// A section header with title and optional action button.
/// Used for list sections, settings groups, and content categories.
struct RLSectionHeader: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let subtitle: String?
    let actionLabel: String?
    let actionIcon: String?
    let action: (() -> Void)?

    init(
        _ title: String,
        subtitle: String? = nil,
        actionLabel: String? = nil,
        actionIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionLabel = actionLabel
        self.actionIcon = actionIcon
        self.action = action
    }

    var body: some View {
        let theme = themeManager.current

        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.titleSmall)
                    .foregroundStyle(theme.colors.text)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer()

            if let action = action {
                Button(action: action) {
                    HStack(spacing: 4) {
                        if let actionLabel = actionLabel {
                            Text(actionLabel)
                                .font(theme.typography.bodySmall)
                        }
                        if let actionIcon = actionIcon {
                            Image(systemName: actionIcon)
                                .font(theme.typography.bodySmall)
                        }
                    }
                    .foregroundStyle(theme.colors.accent)
                }
                .accessibilityLabel(actionLabel ?? "Action")
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
    }
}

// MARK: - Convenience Initializers

extension RLSectionHeader {
    /// Creates a simple section header with just a title
    static func simple(_ title: String) -> RLSectionHeader {
        RLSectionHeader(title)
    }

    /// Creates a section header with "See All" action
    static func withSeeAll(_ title: String, action: @escaping () -> Void) -> RLSectionHeader {
        RLSectionHeader(
            title,
            actionLabel: "See All",
            actionIcon: "chevron.right",
            action: action
        )
    }

    /// Creates a section header with add action
    static func withAdd(_ title: String, action: @escaping () -> Void) -> RLSectionHeader {
        RLSectionHeader(
            title,
            actionIcon: "plus",
            action: action
        )
    }
}

// MARK: - Preview

#Preview("RLSectionHeader") {
    VStack(spacing: 0) {
        // Simple
        RLSectionHeader.simple("Recent Workouts")
        Divider()

        // With subtitle
        RLSectionHeader(
            "This Week",
            subtitle: "Jan 1 - Jan 7"
        )
        Divider()

        // With See All
        RLSectionHeader.withSeeAll("Templates") { }
        Divider()

        // With Add
        RLSectionHeader.withAdd("Exercises") { }
        Divider()

        // Custom action
        RLSectionHeader(
            "Volume Trends",
            actionLabel: "Filter",
            actionIcon: "line.3.horizontal.decrease"
        ) { }
    }
    .background(Color(hex: "0A0A0C"))
    .environment(ThemeManager())
}
