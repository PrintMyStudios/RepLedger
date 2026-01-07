import SwiftUI

/// Reusable header action button with consistent styling from theme tokens.
/// Supports optional badge overlays for notifications or active states.
struct HeaderActionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let action: () -> Void
    var badge: HeaderBadge?
    var accessibilityLabel: String?

    /// Badge types for header action buttons
    enum HeaderBadge {
        case notification  // Red dot for notifications
        case activeFilter  // Green dot for active filters
    }

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: theme.header.iconSize, weight: theme.header.iconWeight))
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(width: theme.header.buttonVisualSize, height: theme.header.buttonVisualSize)
                    .background(theme.colors.elevated)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(theme.colors.border, lineWidth: 1)
                    }

                // Badge overlay
                if let badge {
                    badgeView(for: badge)
                }
            }
            .frame(width: theme.header.buttonTapSize, height: theme.header.buttonTapSize)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel ?? icon.replacingOccurrences(of: ".", with: " "))
    }

    @ViewBuilder
    private func badgeView(for badge: HeaderBadge) -> some View {
        let theme = themeManager.current

        Circle()
            .fill(badge == .notification ? theme.colors.error : theme.colors.accent)
            .frame(width: 8, height: 8)
            .offset(x: 2, y: 0)
    }
}

// MARK: - Preview

#Preview("HeaderActionButton") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        HStack(spacing: 20) {
            HeaderActionButton(icon: "bell.fill", action: {})
            HeaderActionButton(icon: "bell.fill", action: {}, badge: .notification)
            HeaderActionButton(icon: "magnifyingglass", action: {})
            HeaderActionButton(icon: "line.3.horizontal.decrease", action: {}, badge: .activeFilter)
        }
    }
    .environment(ThemeManager())
}
