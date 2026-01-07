import SwiftUI

/// Empty state card shown when user has no workouts yet
struct DashboardEmptyStateCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let onStartWorkout: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.lg) {
            // Icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 48))
                .foregroundStyle(theme.colors.textTertiary)

            // Text
            VStack(spacing: theme.spacing.xs) {
                Text("No Workouts Yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.colors.text)

                Text("Complete your first workout to see your stats here")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // CTA Button
            Button(action: onStartWorkout) {
                Text("Start Your First Workout")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.colors.textOnAccent)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.vertical, theme.spacing.md)
                    .background(theme.colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            }
            .buttonStyle(.plain)
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .stroke(theme.colors.border, lineWidth: 1)
        }
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        DashboardEmptyStateCard(onStartWorkout: { })
            .padding()
    }
    .environment(ThemeManager())
}
