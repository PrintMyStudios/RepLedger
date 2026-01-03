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
        // Load persisted theme or default to Obsidian
        let savedThemeID = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeID.obsidian.rawValue
        let themeID = ThemeID(rawValue: savedThemeID) ?? .obsidian
        self.current = Self.theme(for: themeID)
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

// MARK: - Environment Key

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
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
                        .foregroundStyle(isSelected ? theme.colors.accent : .primary)

                    Text(theme.id.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.colors.accent : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name) theme")
        .accessibilityHint(theme.id.description)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
