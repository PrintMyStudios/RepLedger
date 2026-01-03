import SwiftUI

/// An empty state view with icon, title, subtitle, and optional action.
/// Used when lists are empty or features are not yet available.
struct RLEmptyState: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let title: String
    let subtitle: String
    let actionLabel: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        subtitle: String,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionLabel = actionLabel
        self.action = action
    }

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.lg) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)

            // Text content
            VStack(spacing: theme.spacing.sm) {
                Text(title)
                    .font(theme.typography.titleSmall)
                    .foregroundStyle(theme.colors.text)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            // Action button
            if let actionLabel = actionLabel, let action = action {
                RLButton(actionLabel, style: .primary, size: .medium, action: action)
                    .padding(.top, theme.spacing.sm)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Common Empty States

extension RLEmptyState {
    /// Empty workout history
    static func noWorkouts(action: @escaping () -> Void) -> RLEmptyState {
        RLEmptyState(
            icon: "figure.strengthtraining.traditional",
            title: "No Workouts Yet",
            subtitle: "Start your first workout to see your training history here.",
            actionLabel: "Start Workout",
            action: action
        )
    }

    /// Empty templates
    static func noTemplates(action: @escaping () -> Void) -> RLEmptyState {
        RLEmptyState(
            icon: "doc.on.doc",
            title: "No Templates",
            subtitle: "Create templates to quickly start your favorite workouts.",
            actionLabel: "Create Template",
            action: action
        )
    }

    /// Empty exercise history
    static func noExerciseHistory() -> RLEmptyState {
        RLEmptyState(
            icon: "clock",
            title: "No History",
            subtitle: "Complete workouts with this exercise to see your progress."
        )
    }

    /// No search results
    static func noSearchResults(query: String) -> RLEmptyState {
        RLEmptyState(
            icon: "magnifyingglass",
            title: "No Results",
            subtitle: "No exercises found for \"\(query)\". Try a different search term."
        )
    }

    /// Coach clients (placeholder for v1)
    static func noClients() -> RLEmptyState {
        RLEmptyState(
            icon: "person.2",
            title: "No Clients Yet",
            subtitle: "Client management is coming soon. Stay tuned for updates."
        )
    }

    /// Feature coming soon
    static func comingSoon(feature: String) -> RLEmptyState {
        RLEmptyState(
            icon: "sparkles",
            title: "Coming Soon",
            subtitle: "\(feature) will be available in a future update."
        )
    }

    /// No PRs
    static func noPRs() -> RLEmptyState {
        RLEmptyState(
            icon: "trophy",
            title: "No Personal Records",
            subtitle: "Keep training to set your first personal records!"
        )
    }
}

// MARK: - Preview

#Preview("RLEmptyState") {
    ScrollView {
        VStack(spacing: 32) {
            RLEmptyState.noWorkouts { }

            Divider()

            RLEmptyState.noTemplates { }

            Divider()

            RLEmptyState.noSearchResults(query: "squats")

            Divider()

            RLEmptyState.comingSoon(feature: "Advanced Analytics")
        }
        .padding()
    }
    .background(Color(hex: "0A0A0C"))
    .environment(ThemeManager())
}
