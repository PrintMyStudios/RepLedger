import SwiftUI

/// Obsidian: Premium dark theme with subtle gradients and minimal chrome.
/// Designed for focused, distraction-free training sessions.
struct ObsidianTheme: Theme {
    let name = "Obsidian"
    let id = ThemeID.obsidian

    let colors = ThemeColors(
        // Backgrounds - deep blacks with subtle warmth
        background: Color(hex: "0A0A0C"),
        surface: Color(hex: "141416"),
        elevated: Color(hex: "1C1C1F"),

        // Text - warm whites for readability
        text: Color(hex: "F5F5F7"),
        textSecondary: Color(hex: "A1A1A6"),
        textTertiary: Color(hex: "636366"),

        // Accent - warm amber/gold for premium feel
        accent: Color(hex: "F5A623"),
        accentSecondary: Color(hex: "D4920D"),

        // Semantic colors
        success: Color(hex: "34C759"),
        warning: Color(hex: "FF9F0A"),
        error: Color(hex: "FF453A"),

        // Dividers - subtle separators
        divider: Color(hex: "2C2C2E"),
        border: Color(hex: "3A3A3C"),

        // Overlay for modals
        overlay: Color.black.opacity(0.6)
    )

    let typography = ThemeTypography.default
    let spacing = ThemeSpacing.default
    let cornerRadius = ThemeCornerRadius.default
    let shadows = ThemeShadows.forDarkTheme()
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
