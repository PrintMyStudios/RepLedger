import SwiftUI

/// Shared sheet for all "Coming Soon" Coach features.
/// Shown once per user via `hasSeenCoachComingSoon` setting.
struct ComingSoonSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.userSettings) private var settings

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.xl) {
                    // Header icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 56))
                        .foregroundStyle(theme.colors.accent)
                        .padding(.top, theme.spacing.xl)

                    // Title
                    Text("Coming Soon")
                        .font(theme.typography.titleMedium)
                        .foregroundStyle(theme.colors.text)

                    // Subtitle
                    Text("These features are in development and will be available in a future update.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, theme.spacing.lg)

                    // Feature list
                    VStack(spacing: theme.spacing.md) {
                        FeatureItem(
                            icon: "person.badge.plus",
                            title: "Client Invitations",
                            description: "Send invites and onboard new clients"
                        )

                        FeatureItem(
                            icon: "doc.badge.plus",
                            title: "Template Assignment",
                            description: "Assign workout templates to your clients"
                        )

                        FeatureItem(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress Tracking",
                            description: "Monitor client workouts and compliance"
                        )

                        FeatureItem(
                            icon: "message",
                            title: "Client Messaging",
                            description: "Communicate directly with your clients"
                        )
                    }
                    .padding(.horizontal, theme.spacing.md)

                    Spacer(minLength: theme.spacing.xl)

                    // CTA button
                    RLButton("Got It", icon: "checkmark") {
                        settings.hasSeenCoachComingSoon = true
                        dismiss()
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.lg)
                }
            }
            .background(theme.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        settings.hasSeenCoachComingSoon = true
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Feature Item

private struct FeatureItem: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let title: String
    let description: String

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(theme.colors.accent)
                .frame(width: 44, height: 44)
                .background(theme.colors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)

                Text(description)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - "Coming Soon" Action Button

/// A button styled for "Coming Soon" features.
/// Tappable but styled to look inactive (secondary style + pill badge).
struct ComingSoonButton: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let title: String
    let icon: String?
    @Binding var showSheet: Bool

    init(_ title: String, icon: String? = nil, showSheet: Binding<Bool>) {
        self.title = title
        self.icon = icon
        self._showSheet = showSheet
    }

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.sm) {
            Button {
                if !settings.hasSeenCoachComingSoon {
                    showSheet = true
                }
                // After first view, subsequent taps do nothing (or could add haptic)
            } label: {
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(theme.colors.accent)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
                .overlay {
                    RoundedRectangle(cornerRadius: theme.cornerRadius.small)
                        .stroke(theme.colors.accent.opacity(0.5), lineWidth: 1.5)
                }
            }
            .opacity(0.7) // Slightly dimmed to indicate inactive

            RLPill("Coming soon", style: .subtle, color: .neutral, size: .small)
        }
    }
}

// MARK: - Preview

#Preview("ComingSoonSheet") {
    ComingSoonSheet()
        .environment(ThemeManager())
}

#Preview("ComingSoonButton") {
    struct PreviewWrapper: View {
        @State private var showSheet = false

        var body: some View {
            VStack(spacing: 20) {
                ComingSoonButton("Assign Template", icon: "doc.badge.plus", showSheet: $showSheet)
                ComingSoonButton("Invite Client", icon: "person.badge.plus", showSheet: $showSheet)
            }
            .padding()
            .background(ObsidianTheme().colors.surfaceDeep)
            .sheet(isPresented: $showSheet) {
                ComingSoonSheet()
            }
        }
    }

    return PreviewWrapper()
        .environment(ThemeManager())
}
