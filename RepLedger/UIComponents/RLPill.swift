import SwiftUI

/// Pill style variants
enum RLPillStyle {
    case filled      // Solid background
    case outlined    // Border only
    case subtle      // Very light background
}

/// Pill semantic colors
enum RLPillColor {
    case accent
    case success
    case warning
    case error
    case neutral

    func backgroundColor(for theme: any Theme, style: RLPillStyle) -> Color {
        switch style {
        case .filled:
            return solidColor(for: theme)
        case .outlined:
            return .clear
        case .subtle:
            return solidColor(for: theme).opacity(0.15)
        }
    }

    func foregroundColor(for theme: any Theme, style: RLPillStyle) -> Color {
        switch style {
        case .filled:
            return theme.colors.textOnAccent
        case .outlined, .subtle:
            return solidColor(for: theme)
        }
    }

    func borderColor(for theme: any Theme) -> Color {
        solidColor(for: theme)
    }

    private func solidColor(for theme: any Theme) -> Color {
        switch self {
        case .accent: return theme.colors.accent
        case .success: return theme.colors.success
        case .warning: return theme.colors.warning
        case .error: return theme.colors.error
        case .neutral: return theme.colors.textSecondary
        }
    }
}

/// A small, rounded tag/badge component for status indicators, muscle groups, etc.
struct RLPill: View {
    @Environment(ThemeManager.self) private var themeManager

    let text: String
    let icon: String?
    let style: RLPillStyle
    let color: RLPillColor
    let size: PillSize

    enum PillSize {
        case small
        case medium

        var font: Font {
            switch self {
            case .small: return .caption2.weight(.medium)
            case .medium: return .caption.weight(.medium)
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            }
        }
    }

    init(
        _ text: String,
        icon: String? = nil,
        style: RLPillStyle = .subtle,
        color: RLPillColor = .accent,
        size: PillSize = .medium
    ) {
        self.text = text
        self.icon = icon
        self.style = style
        self.color = color
        self.size = size
    }

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(size.font)
            }
            Text(text)
                .font(size.font)
        }
        .foregroundStyle(color.foregroundColor(for: theme, style: style))
        .padding(.vertical, size.verticalPadding)
        .padding(.horizontal, size.horizontalPadding)
        .background(color.backgroundColor(for: theme, style: style))
        .clipShape(Capsule())
        .overlay {
            if style == .outlined {
                Capsule()
                    .stroke(color.borderColor(for: theme), lineWidth: 1)
            }
        }
        .accessibilityLabel(text)
    }
}

// MARK: - Convenience Initializers

extension RLPill {
    /// Creates a pill for muscle group display
    static func muscleGroup(_ name: String) -> RLPill {
        RLPill(name, style: .subtle, color: .accent, size: .small)
    }

    /// Creates a completed status pill
    static func completed() -> RLPill {
        RLPill("Completed", icon: "checkmark", style: .filled, color: .success, size: .small)
    }

    /// Creates a PR (personal record) badge
    static func pr() -> RLPill {
        RLPill("PR", icon: "trophy.fill", style: .filled, color: .warning, size: .small)
    }
}

// MARK: - Preview

#Preview("RLPill") {
    VStack(spacing: 16) {
        // Styles
        HStack(spacing: 8) {
            RLPill("Filled", style: .filled)
            RLPill("Outlined", style: .outlined)
            RLPill("Subtle", style: .subtle)
        }

        // Colors
        HStack(spacing: 8) {
            RLPill("Accent", color: .accent)
            RLPill("Success", color: .success)
            RLPill("Warning", color: .warning)
            RLPill("Error", color: .error)
        }

        // With icons
        HStack(spacing: 8) {
            RLPill("Chest", icon: "figure.arms.open", style: .subtle)
            RLPill.completed()
            RLPill.pr()
        }

        // Sizes
        HStack(spacing: 8) {
            RLPill("Small", size: .small)
            RLPill("Medium", size: .medium)
        }

        // Muscle groups example
        HStack(spacing: 6) {
            RLPill.muscleGroup("Chest")
            RLPill.muscleGroup("Triceps")
            RLPill.muscleGroup("Shoulders")
        }
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
