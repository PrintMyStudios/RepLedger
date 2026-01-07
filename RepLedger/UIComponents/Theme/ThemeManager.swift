import SwiftUI

// MARK: - Theme Manager

/// Manages the current theme and persists user selection.
/// Use via environment: `@Environment(ThemeManager.self) var themeManager`
@Observable
final class ThemeManager {
    // MARK: - Properties

    private(set) var current: any Theme

    var currentID: ThemeID {
        current.id
    }

    // MARK: - Available Themes

    static let availableThemes: [any Theme] = [
        ObsidianTheme(),
        StudioTheme(),
        ForgeTheme()
    ]

    // MARK: - Initialization

    init() {
        // v1: Always use ObsidianTheme (neon green) - theme picker removed
        // Force ObsidianTheme regardless of any persisted setting
        self.current = ObsidianTheme()

        // Clear any old theme preference to ensure clean state
        UserDefaults.standard.set(ThemeID.obsidian.rawValue, forKey: "selectedTheme")
    }

    // MARK: - Theme Selection

    func setTheme(_ id: ThemeID) {
        current = Self.theme(for: id)
        UserDefaults.standard.set(id.rawValue, forKey: "selectedTheme")
    }

    // MARK: - Helper

    static func theme(for id: ThemeID) -> any Theme {
        switch id {
        case .obsidian: return ObsidianTheme()
        case .studio: return StudioTheme()
        case .forge: return ForgeTheme()
        }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Applies the current theme's background color to the view.
    func themedBackground() -> some View {
        modifier(ThemedBackgroundModifier())
    }
}

private struct ThemedBackgroundModifier: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    func body(content: Content) -> some View {
        content
            .background(themeManager.current.colors.background)
    }
}

// MARK: - Theme Preview Helper

struct ThemePreviewCard: View {
    let theme: any Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Color preview stack
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.colors.background)
                        .frame(width: 24, height: 40)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.colors.surface)
                        .frame(width: 24, height: 40)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.colors.accent)
                        .frame(width: 24, height: 40)
                }
                .padding(8)
                .background(theme.colors.elevated)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(spacing: 4) {
                    Text(theme.name)
                        .font(.headline)
                        .foregroundStyle(isSelected ? theme.colors.accent : theme.colors.text)

                    Text(theme.id.description)
                        .font(.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.colors.accent : theme.colors.border.opacity(0.5), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name) theme")
        .accessibilityHint(theme.id.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
