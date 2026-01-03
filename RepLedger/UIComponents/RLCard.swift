import SwiftUI

/// A themed card container with consistent styling across the app.
/// Uses theme tokens for background, corner radius, and shadow.
struct RLCard<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let content: () -> Content
    var padding: CGFloat?
    var elevated: Bool

    init(
        elevated: Bool = false,
        padding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.elevated = elevated
        self.padding = padding
        self.content = content
    }

    var body: some View {
        let theme = themeManager.current

        content()
            .padding(padding ?? theme.spacing.md)
            .background(elevated ? theme.colors.elevated : theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .rlShadow(elevated ? theme.shadows.medium : theme.shadows.subtle)
    }
}

// MARK: - Card Variants

extension RLCard {
    /// Creates a card with no shadow (flat style)
    static func flat<C: View>(
        padding: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> C
    ) -> some View {
        FlatCard(padding: padding, content: content)
    }
}

private struct FlatCard<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager

    let padding: CGFloat?
    let content: () -> Content

    var body: some View {
        let theme = themeManager.current

        content()
            .padding(padding ?? theme.spacing.md)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - Preview

#Preview("RLCard") {
    VStack(spacing: 16) {
        RLCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Standard Card")
                    .font(.headline)
                Text("With default surface background")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        RLCard(elevated: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Elevated Card")
                    .font(.headline)
                Text("With elevated background and stronger shadow")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding()
    .background(Color(hex: "0A0A0C"))
    .environment(ThemeManager())
}
