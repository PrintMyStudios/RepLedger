import SwiftUI

/// Collapsible section header for history timeline.
/// Shows section title, stats badge, and animated chevron with improved typography.
struct CollapsibleSectionHeader: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let statsText: String
    let isCollapsed: Bool
    let onToggle: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Section title - using Dynamic Type .footnote for better readability
                Text(title)
                    .font(.footnote.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(theme.colors.textSecondary)

                // Stats badge - using Dynamic Type .caption
                Text(statsText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.colors.textTertiary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(theme.colors.elevated)
                    .clipShape(Capsule())

                Spacer()

                // Animated chevron
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isCollapsed)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(statsText)")
        .accessibilityHint(isCollapsed ? "Double tap to expand" : "Double tap to collapse")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview("CollapsibleSectionHeader") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack(spacing: 24) {
            CollapsibleSectionHeader(
                title: "THIS WEEK",
                statsText: "4 Sessions • 42.1k Vol",
                isCollapsed: false,
                onToggle: {}
            )

            CollapsibleSectionHeader(
                title: "LAST WEEK",
                statsText: "3 Sessions • 38.5k Vol",
                isCollapsed: true,
                onToggle: {}
            )

            CollapsibleSectionHeader(
                title: "OCTOBER 2025",
                statsText: "12 Sessions • 145.2k Vol",
                isCollapsed: false,
                onToggle: {}
            )
        }
        .padding()
    }
    .environment(ThemeManager())
}
