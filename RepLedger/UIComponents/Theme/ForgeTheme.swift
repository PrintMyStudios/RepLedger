import SwiftUI

/// Forge: Bold athletic theme with higher contrast and punchy accents.
/// Energetic and motivating, designed to get you fired up for training.
struct ForgeTheme: Theme {
    let name = "Forge"
    let id = ThemeID.forge

    let colors = ThemeColors(
        // Backgrounds - deep charcoal with warmth
        background: Color(hex: "121212"),
        surface: Color(hex: "1E1E1E"),
        elevated: Color(hex: "2A2A2A"),
        inputBackground: Color(hex: "0F0F0F"),  // Dark background for inputs
        surfaceDeep: Color(hex: "0A0A0C"),      // Deepest background for previews/modals

        // Text - pure white for maximum contrast
        text: Color(hex: "FFFFFF"),
        textSecondary: Color(hex: "B3B3B3"),
        textTertiary: Color(hex: "737373"),
        textOnAccent: Color(hex: "FFFFFF"),     // White text on red accent

        // Accent - vibrant red-orange for energy
        accent: Color(hex: "FF4136"),
        accentSecondary: Color(hex: "E83C30"),
        accentGold: Color(hex: "FFD700"),
        accentOrange: Color(hex: "FF9F43"),

        // Semantic colors - bold and clear
        success: Color(hex: "2ECC40"),
        warning: Color(hex: "FFDC00"),
        error: Color(hex: "FF4136"),

        // Dividers - visible but not distracting
        divider: Color(hex: "3D3D3D"),
        border: Color(hex: "4A4A4A"),

        // Overlay for modals
        overlay: Color.black.opacity(0.7),
        completedSetTint: Color(hex: "1A2A1E") // Dark green tint for completed sets
    )

    let typography = ThemeTypography.default
    let spacing = ThemeSpacing.default
    let cornerRadius = ThemeCornerRadius.default
    let shadows = ThemeShadows.forDarkTheme()
    let header = ThemeHeaderTokens.default
}
