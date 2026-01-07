import SwiftUI

/// Rich empty state view for Coach tab when no clients exist.
/// Shows "No Clients Yet" with informational cards about Coach features.
struct CoachEmptyStateView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var showComingSoonSheet: Bool

    var body: some View {
        let theme = themeManager.current

        ScrollView {
            VStack(spacing: theme.spacing.xl) {
                Spacer(minLength: theme.spacing.xl)

                // Main empty state
                emptyStateHeader

                // How Coach Works card
                howCoachWorksCard

                // Why Coach benefits card
                whyCoachCard

                Spacer(minLength: theme.spacing.xl)
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    // MARK: - Empty State Header

    private var emptyStateHeader: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.lg) {
            Image(systemName: "person.2")
                .font(.system(size: 56))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)

            VStack(spacing: theme.spacing.sm) {
                Text("No Clients Yet")
                    .font(theme.typography.titleSmall)
                    .foregroundStyle(theme.colors.text)
                    .multilineTextAlignment(.center)

                Text("Your coaching workspace is ready. Invite clients to get started.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            // Invite button (coming soon)
            ComingSoonButton("Invite Client", icon: "person.badge.plus", showSheet: $showComingSoonSheet)
                .padding(.top, theme.spacing.sm)
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity)
    }

    // MARK: - How Coach Works Card

    private var howCoachWorksCard: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("How Coach Works")
                .font(theme.typography.titleSmall)
                .foregroundStyle(theme.colors.text)

            VStack(spacing: theme.spacing.sm) {
                HowItWorksRow(
                    icon: "person.badge.plus",
                    title: "Invite Clients",
                    subtitle: "Send invites via email or link",
                    showPill: true
                )

                HowItWorksRow(
                    icon: "doc.badge.plus",
                    title: "Assign Programs",
                    subtitle: "Share your templates with clients",
                    showPill: true
                )

                HowItWorksRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Compliance",
                    subtitle: "Monitor progress and adherence",
                    showPill: true
                )
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }

    // MARK: - Why Coach Card

    private var whyCoachCard: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Why Coach?")
                .font(theme.typography.titleSmall)
                .foregroundStyle(theme.colors.text)

            VStack(spacing: theme.spacing.sm) {
                BenefitRow(
                    icon: "infinity",
                    title: "Unlimited Clients",
                    subtitle: "No cap on the number of clients per seat"
                )

                BenefitRow(
                    icon: "doc.on.doc",
                    title: "Program Library",
                    subtitle: "Build and assign structured programs"
                )

                BenefitRow(
                    icon: "eye",
                    title: "Full Visibility",
                    subtitle: "See every workout your clients complete"
                )
            }
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - How It Works Row

private struct HowItWorksRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let title: String
    let subtitle: String
    var showPill: Bool = false

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(theme.colors.accent)
                .frame(width: 32, height: 32)
                .background(theme.colors.accent.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: theme.spacing.sm) {
                    Text(title)
                        .font(theme.typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(theme.colors.text)

                    if showPill {
                        RLPill("Soon", style: .subtle, color: .neutral, size: .small)
                    }
                }

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Benefit Row

private struct BenefitRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(theme.colors.success)
                .frame(width: 32, height: 32)
                .background(theme.colors.success.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)

                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("CoachEmptyStateView") {
    struct PreviewWrapper: View {
        @State private var showSheet = false

        var body: some View {
            NavigationStack {
                CoachEmptyStateView(showComingSoonSheet: $showSheet)
                    .background(ObsidianTheme().colors.surfaceDeep)
                    .navigationTitle("Clients")
            }
            .sheet(isPresented: $showSheet) {
                ComingSoonSheet()
            }
        }
    }

    return PreviewWrapper()
        .environment(ThemeManager())
}
