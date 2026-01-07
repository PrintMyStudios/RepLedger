import SwiftUI

// MARK: - Theme Protocol

/// Defines the complete set of design tokens for a RepLedger theme.
/// All UI components must use these tokens to ensure global theme switching works correctly.
protocol Theme {
    // MARK: - Identity
    var name: String { get }
    var id: ThemeID { get }

    // MARK: - Colors
    var colors: ThemeColors { get }

    // MARK: - Typography
    var typography: ThemeTypography { get }

    // MARK: - Spacing
    var spacing: ThemeSpacing { get }

    // MARK: - Corner Radii
    var cornerRadius: ThemeCornerRadius { get }

    // MARK: - Shadows
    var shadows: ThemeShadows { get }

    // MARK: - Header
    var header: ThemeHeaderTokens { get }
}

// MARK: - Theme Identifier

enum ThemeID: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }
    case obsidian
    case studio
    case forge

    var displayName: String {
        switch self {
        case .obsidian: return "Obsidian"
        case .studio: return "Studio"
        case .forge: return "Forge"
        }
    }

    var description: String {
        switch self {
        case .obsidian: return "Premium dark, subtle gradients"
        case .studio: return "Clean light, editorial spacing"
        case .forge: return "Bold athletic, high contrast"
        }
    }
}

// MARK: - Theme Colors

struct ThemeColors {
    // Backgrounds
    let background: Color
    let surface: Color
    let elevated: Color
    let inputBackground: Color  // Darker background for input fields
    let surfaceDeep: Color      // Deepest background layer (for previews, modals)

    // Text
    let text: Color
    let textSecondary: Color
    let textTertiary: Color
    let textOnAccent: Color     // Contrasting text for accent backgrounds

    // Accent & Semantic
    let accent: Color
    let accentSecondary: Color
    let accentGold: Color      // For PRs, achievements
    let accentOrange: Color    // For warnings, partial progress
    let success: Color
    let warning: Color
    let error: Color

    // Dividers & Borders
    let divider: Color
    let border: Color

    // Special
    let overlay: Color
    let completedSetTint: Color // Green-tinted background for completed sets
}

// MARK: - Theme Typography

struct ThemeTypography {
    // Title styles
    let titleLarge: Font
    let titleMedium: Font
    let titleSmall: Font

    // Body styles
    let bodyLarge: Font
    let body: Font
    let bodySmall: Font

    // Caption
    let caption: Font
    let captionSmall: Font

    // Weights for manual composition
    let weightRegular: Font.Weight
    let weightMedium: Font.Weight
    let weightSemibold: Font.Weight
    let weightBold: Font.Weight
}

extension ThemeTypography {
    /// Default typography using system fonts with Dynamic Type support
    static var `default`: ThemeTypography {
        ThemeTypography(
            titleLarge: .largeTitle.weight(.bold),
            titleMedium: .title2.weight(.semibold),
            titleSmall: .title3.weight(.semibold),
            bodyLarge: .body.weight(.medium),
            body: .body,
            bodySmall: .subheadline,
            caption: .caption,
            captionSmall: .caption2,
            weightRegular: .regular,
            weightMedium: .medium,
            weightSemibold: .semibold,
            weightBold: .bold
        )
    }
}

// MARK: - Theme Spacing

struct ThemeSpacing {
    let xs: CGFloat   // 4
    let sm: CGFloat   // 8
    let md: CGFloat   // 16
    let lg: CGFloat   // 24
    let xl: CGFloat   // 32
    let xxl: CGFloat  // 48
}

extension ThemeSpacing {
    static var `default`: ThemeSpacing {
        ThemeSpacing(
            xs: 4,
            sm: 8,
            md: 16,
            lg: 24,
            xl: 32,
            xxl: 48
        )
    }
}

// MARK: - Theme Corner Radius

struct ThemeCornerRadius {
    let small: CGFloat   // 8
    let medium: CGFloat  // 12
    let large: CGFloat   // 16
    let full: CGFloat    // 999 (pill shape)
}

extension ThemeCornerRadius {
    static var `default`: ThemeCornerRadius {
        ThemeCornerRadius(
            small: 8,
            medium: 12,
            large: 16,
            full: 999
        )
    }
}

// MARK: - Theme Shadows

struct ThemeShadows {
    let subtle: RLShadow
    let medium: RLShadow
    let prominent: RLShadow
    let neonGlow: RLShadow     // Neon glow effect for CTAs
    let card: RLShadow         // Card shadow
}

struct RLShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension ThemeShadows {
    static func forDarkTheme(accentColor: Color = Color(hex: "00FF66")) -> ThemeShadows {
        ThemeShadows(
            subtle: RLShadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2),
            medium: RLShadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4),
            prominent: RLShadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 8),
            neonGlow: RLShadow(color: accentColor.opacity(0.4), radius: 15, x: 0, y: 0),
            card: RLShadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 4)
        )
    }

    static func forLightTheme(accentColor: Color = Color(hex: "00FF66")) -> ThemeShadows {
        ThemeShadows(
            subtle: RLShadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2),
            medium: RLShadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4),
            prominent: RLShadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 8),
            neonGlow: RLShadow(color: accentColor.opacity(0.3), radius: 12, x: 0, y: 0),
            card: RLShadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)
        )
    }
}

// MARK: - Shadow View Modifier

extension View {
    func rlShadow(_ shadow: RLShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - Theme Header Tokens

/// Centralized header styling tokens for consistent headers across all tabs.
/// All header components should use these tokens instead of hardcoded values.
struct ThemeHeaderTokens {
    // Typography
    let pageTitleFont: Font          // 28pt bold - "History", "Start"
    let greetingFont: Font           // 13pt semibold uppercase - "GOOD EVENING, ALEX"
    let dashboardMessageFont: Font   // 22pt bold - "Ready to crush it?"
    let subtitleFont: Font           // 14pt regular - "42 workouts completed"

    // Button dimensions
    let buttonVisualSize: CGFloat    // 40 (visual size)
    let buttonTapSize: CGFloat       // 44 (tap target, Apple minimum)
    let iconSize: CGFloat            // 16
    let iconWeight: Font.Weight      // .semibold

    // Pill container
    let pillHeight: CGFloat          // 44
    let pillPadding: CGFloat         // 6 (horizontal padding inside pill)
    let pillButtonSpacing: CGFloat   // 0 (icons touch divider)
    let pillDividerHeight: CGFloat   // 24
}

extension ThemeHeaderTokens {
    /// Default header tokens used across all themes
    static var `default`: ThemeHeaderTokens {
        ThemeHeaderTokens(
            pageTitleFont: .system(size: 28, weight: .bold),
            greetingFont: .system(size: 13, weight: .semibold),
            dashboardMessageFont: .system(size: 22, weight: .bold),
            subtitleFont: .system(size: 14, weight: .regular),
            buttonVisualSize: 40,
            buttonTapSize: 44,
            iconSize: 16,
            iconWeight: .semibold,
            pillHeight: 44,
            pillPadding: 6,
            pillButtonSpacing: 0,
            pillDividerHeight: 24
        )
    }
}
