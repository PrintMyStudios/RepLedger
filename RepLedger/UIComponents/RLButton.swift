import SwiftUI

/// Button style variants for consistent styling across the app.
enum RLButtonStyle {
    case primary    // Filled with accent color
    case secondary  // Outlined with accent color
    case tertiary   // Text-only with accent color
    case destructive // Filled with error color
}

/// Button size variants
enum RLButtonSize {
    case small
    case medium
    case large

    var verticalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 16
        case .large: return 24
        }
    }

    var font: Font {
        switch self {
        case .small: return .subheadline.weight(.medium)
        case .medium: return .body.weight(.semibold)
        case .large: return .body.weight(.semibold)
        }
    }
}

/// A themed button with multiple style variants.
struct RLButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let icon: String?
    let style: RLButtonStyle
    let size: RLButtonSize
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        style: RLButtonStyle = .primary,
        size: RLButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor(for: theme))
                } else if let icon = icon {
                    Image(systemName: icon)
                }

                Text(title)
            }
            .font(size.font)
            .foregroundStyle(foregroundColor(for: theme))
            .padding(.vertical, size.verticalPadding)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: style == .primary || style == .destructive ? .infinity : nil)
            .background(backgroundColor(for: theme))
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
            .overlay {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: theme.cornerRadius.small)
                        .stroke(theme.colors.accent, lineWidth: 1.5)
                }
            }
        }
        .disabled(isDisabled || isLoading)
        .opacity((isDisabled || isLoading) ? 0.6 : 1.0)
        .accessibilityLabel(isLoading ? "\(title), loading" : title)
        .accessibilityAddTraits(.isButton)
    }

    private func backgroundColor(for theme: any Theme) -> Color {
        switch style {
        case .primary:
            return theme.colors.accent
        case .secondary:
            return .clear
        case .tertiary:
            return .clear
        case .destructive:
            return theme.colors.error
        }
    }

    private func foregroundColor(for theme: any Theme) -> Color {
        switch style {
        case .primary:
            return theme.colors.textOnAccent
        case .secondary:
            return theme.colors.accent
        case .tertiary:
            return theme.colors.accent
        case .destructive:
            return theme.colors.textOnAccent
        }
    }
}

// MARK: - Icon-only Button

struct RLIconButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let size: CGFloat
    let action: () -> Void

    init(
        icon: String,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundStyle(theme.colors.text)
                .frame(width: size, height: size)
                .background(theme.colors.surface)
                .clipShape(Circle())
        }
        .accessibilityLabel(icon.replacingOccurrences(of: ".", with: " "))
    }
}

// MARK: - Preview

#Preview("RLButton") {
    VStack(spacing: 16) {
        RLButton("Primary Button", icon: "plus") { }

        RLButton("Secondary", style: .secondary) { }

        RLButton("Tertiary", style: .tertiary) { }

        RLButton("Delete", icon: "trash", style: .destructive) { }

        RLButton("Loading", isLoading: true) { }

        RLButton("Disabled", isDisabled: true) { }

        HStack(spacing: 12) {
            RLButton("Small", size: .small) { }
            RLButton("Medium", size: .medium) { }
            RLButton("Large", size: .large) { }
        }
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
