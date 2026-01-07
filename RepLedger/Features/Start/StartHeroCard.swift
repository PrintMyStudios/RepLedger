import SwiftUI

/// Hero card for starting workouts with Quick Start and From Template buttons.
struct StartHeroCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let onQuickStart: () -> Void
    let onFromTemplate: () -> Void

    private let buttonHeight: CGFloat = 48

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: 16) {
            // Header row with lightning icon and text
            HStack(spacing: 12) {
                // Lightning icon in green circle
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(theme.colors.textOnAccent)
                    .frame(width: 32, height: 32)
                    .background(theme.colors.accent)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Start Workout")
                        .font(.headline)
                        .foregroundStyle(theme.colors.text)

                    Text("Quick start or use a template")
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()
            }

            // Buttons
            VStack(spacing: 12) {
                // Quick Start - Primary button
                Button(action: onQuickStart) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("Quick Start")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(theme.colors.textOnAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .background(theme.colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
                    .rlShadow(theme.shadows.subtle)
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("Quick Start workout")
                .accessibilityHint("Start an empty workout immediately")

                // From Template - Secondary button
                Button(action: onFromTemplate) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 14, weight: .medium))
                        Text("From Template")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(theme.colors.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.cornerRadius.small)
                            .stroke(theme.colors.accent, lineWidth: 1.5)
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("From Template")
                .accessibilityHint("Choose a template to start a workout")
            }
        }
        .padding(16)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(theme.colors.border, lineWidth: 1)
        }
        .rlShadow(theme.shadows.card)
    }
}

// MARK: - Scale Button Style

/// Button style that scales down on press for tactile feedback.
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("StartHeroCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        StartHeroCard(
            onQuickStart: { print("Quick Start") },
            onFromTemplate: { print("From Template") }
        )
        .padding(.horizontal, 20)
    }
    .environment(ThemeManager())
}
