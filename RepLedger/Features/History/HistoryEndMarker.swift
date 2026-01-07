import SwiftUI

/// End of history marker displayed at the bottom of the timeline.
struct HistoryEndMarker: View {
    @Environment(ThemeManager.self) private var themeManager

    let totalWorkouts: Int

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.md) {
            // Decorative line with dot
            HStack(spacing: theme.spacing.sm) {
                Rectangle()
                    .fill(theme.colors.divider)
                    .frame(height: 1)

                Circle()
                    .fill(theme.colors.textTertiary)
                    .frame(width: 6, height: 6)

                Rectangle()
                    .fill(theme.colors.divider)
                    .frame(height: 1)
            }
            .padding(.horizontal, theme.spacing.xxl)

            // End text
            VStack(spacing: 4) {
                Text("End of History")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.colors.textSecondary)

                Text("\(totalWorkouts) workout\(totalWorkouts == 1 ? "" : "s") logged")
                    .font(.system(size: 11))
                    .foregroundStyle(theme.colors.textTertiary)
            }

            // Motivational icon
            Image(systemName: "trophy.fill")
                .font(.system(size: 20))
                .foregroundStyle(theme.colors.accentGold.opacity(0.4))
                .padding(.top, theme.spacing.xs)
        }
        .padding(.vertical, theme.spacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("End of history. \(totalWorkouts) workouts logged total.")
    }
}

// MARK: - Preview

#Preview("HistoryEndMarker") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack {
            Spacer()
            HistoryEndMarker(totalWorkouts: 42)
            Spacer()
        }
    }
    .environment(ThemeManager())
}
