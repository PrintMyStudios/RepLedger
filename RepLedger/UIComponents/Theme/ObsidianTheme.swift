import SwiftUI

/// Obsidian: Modern dark theme with neon green accent.
/// Designed for focused, distraction-free training sessions.
struct ObsidianTheme: Theme {
    let name = "Obsidian"
    let id = ThemeID.obsidian

    // Neon green accent color for shadows
    private static let neonGreen = Color(hex: "00FF66")

    let colors = ThemeColors(
        // Backgrounds - deep charcoal
        background: Color(hex: "121212"),
        surface: Color(hex: "1E1E1E"),
        elevated: Color(hex: "2C2C2E"),
        inputBackground: Color(hex: "0A0F0C"),  // Dark, slightly green-tinted for inputs
        surfaceDeep: Color(hex: "0A0A0C"),      // Deepest background for previews/modals

        // Text - pure whites for contrast
        text: Color(hex: "FFFFFF"),
        textSecondary: Color(hex: "A1A1AA"),
        textTertiary: Color(hex: "6B7280"),
        textOnAccent: Color(hex: "121212"),     // Dark text on neon green accent

        // Accent - neon green
        accent: Color(hex: "00FF66"),
        accentSecondary: Color(hex: "00CC52"),
        accentGold: Color(hex: "FFD700"),      // For PRs, achievements
        accentOrange: Color(hex: "FF9F43"),    // For warnings, partial progress

        // Semantic colors
        success: Color(hex: "00FF66"),         // Match accent for consistency
        warning: Color(hex: "FF9F43"),
        error: Color(hex: "FF453A"),

        // Dividers - subtle separators
        divider: Color(hex: "3A3A3C"),
        border: Color(hex: "3A3A3C"),

        // Overlay for modals
        overlay: Color.black.opacity(0.6),
        completedSetTint: Color(hex: "15261D") // Green-tinted background for completed sets
    )

    let typography = ThemeTypography.default
    let spacing = ThemeSpacing.default
    let cornerRadius = ThemeCornerRadius.default
    let shadows = ThemeShadows.forDarkTheme(accentColor: neonGreen)
    let header = ThemeHeaderTokens.default
}
