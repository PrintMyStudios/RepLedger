import SwiftUI

/// Studio: Clean light theme with editorial spacing and quiet accents.
/// Professional and refined, ideal for detailed review and analysis.
struct StudioTheme: Theme {
    let name = "Studio"
    let id = ThemeID.studio

    let colors = ThemeColors(
        // Backgrounds - warm whites
        background: Color(hex: "FAFAFA"),
        surface: Color(hex: "FFFFFF"),
        elevated: Color(hex: "FFFFFF"),
        inputBackground: Color(hex: "F5F5F5"),  // Slightly darker for inputs
        surfaceDeep: Color(hex: "F0F0F0"),      // Deepest background for previews/modals

        // Text - deep grays for excellent readability
        text: Color(hex: "1A1A1A"),
        textSecondary: Color(hex: "6B6B6B"),
        textTertiary: Color(hex: "9B9B9B"),
        textOnAccent: Color(hex: "FFFFFF"),     // White text on blue accent

        // Accent - sophisticated blue-gray
        accent: Color(hex: "3B5998"),
        accentSecondary: Color(hex: "5478C2"),
        accentGold: Color(hex: "FFD700"),
        accentOrange: Color(hex: "FF9F43"),

        // Semantic colors
        success: Color(hex: "28A745"),
        warning: Color(hex: "FFC107"),
        error: Color(hex: "DC3545"),

        // Dividers - subtle light separators
        divider: Color(hex: "E8E8E8"),
        border: Color(hex: "D1D1D1"),

        // Overlay for modals
        overlay: Color.black.opacity(0.4),
        completedSetTint: Color(hex: "E8F5E9") // Light green tint for completed sets
    )

    let typography = ThemeTypography.default
    let spacing = ThemeSpacing.default
    let cornerRadius = ThemeCornerRadius.default
    let shadows = ThemeShadows.forLightTheme()
    let header = ThemeHeaderTokens.default
}
