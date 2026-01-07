import SwiftUI

/// Reusable pill container for header action buttons.
/// Provides consistent styling with elevated background and border.
struct HeaderActionPill<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager
    @ViewBuilder let content: () -> Content

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.header.pillButtonSpacing) {
            content()
        }
        .padding(.horizontal, theme.header.pillPadding)
        .frame(height: theme.header.pillHeight)
        .background(theme.colors.elevated)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(theme.colors.border, lineWidth: 1)
        }
    }
}

/// Vertical divider for use inside HeaderActionPill between buttons.
struct HeaderPillDivider: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.current

        Rectangle()
            .fill(theme.colors.divider)
            .frame(width: 1, height: theme.header.pillDividerHeight)
    }
}

// MARK: - Preview

#Preview("HeaderActionPill") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack(spacing: 20) {
            // Single button in pill
            HeaderActionPill {
                HeaderActionButton(icon: "magnifyingglass", action: {})
            }

            // Two buttons with divider
            HeaderActionPill {
                HeaderActionButton(icon: "magnifyingglass", action: {})
                HeaderPillDivider()
                HeaderActionButton(icon: "line.3.horizontal.decrease", action: {}, badge: .activeFilter)
            }

            // Two buttons without divider
            HeaderActionPill {
                HeaderActionButton(icon: "bell.fill", action: {}, badge: .notification)
                HeaderActionButton(icon: "magnifyingglass", action: {})
            }
        }
    }
    .environment(ThemeManager())
}
