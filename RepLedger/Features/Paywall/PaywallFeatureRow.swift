import SwiftUI

/// A row displaying a feature benefit for paywall screens.
struct PaywallFeatureRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let title: String
    let subtitle: String
    let isIncluded: Bool

    init(
        icon: String,
        title: String,
        subtitle: String = "",
        isIncluded: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isIncluded = isIncluded
    }

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            // Feature icon
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(isIncluded ? theme.colors.accent : theme.colors.textTertiary)
                .frame(width: 32)

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.text)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            Spacer()

            // Checkmark
            if isIncluded {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(theme.colors.success)
            }
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - Preview

#Preview("PaywallFeatureRow") {
    VStack(spacing: 12) {
        PaywallFeatureRow(
            icon: "doc.on.doc.fill",
            title: "Unlimited Templates",
            subtitle: "Create as many workout templates as you need"
        )

        PaywallFeatureRow(
            icon: "chart.line.uptrend.xyaxis",
            title: "Advanced Analytics",
            subtitle: "Volume trends, muscle group breakdowns"
        )

        PaywallFeatureRow(
            icon: "lock.fill",
            title: "Locked Feature",
            subtitle: "Not included in this tier",
            isIncluded: false
        )
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
