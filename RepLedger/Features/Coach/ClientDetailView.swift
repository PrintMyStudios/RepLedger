import SwiftUI

/// Detail view for a client showing overview, templates, and activity.
struct ClientDetailView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    let client: any CoachClientPresentable

    @State private var showComingSoonSheet = false

    var body: some View {
        let theme = themeManager.current

        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                // Client header card
                clientHeader

                // Stats summary
                clientStatsSummary

                // Assigned Templates section
                assignedTemplatesSection

                // Recent Activity section
                recentActivitySection

                // Actions section
                actionsSection
            }
            .padding(.vertical, theme.spacing.md)
        }
        .background(theme.colors.background)
        .navigationTitle(client.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showComingSoonSheet = true
                    } label: {
                        Label("Assign Template", systemImage: "doc.badge.plus")
                    }

                    Button {
                        showComingSoonSheet = true
                    } label: {
                        Label("Send Message", systemImage: "message")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showComingSoonSheet = true
                    } label: {
                        Label("Remove Client", systemImage: "person.badge.minus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showComingSoonSheet) {
            ComingSoonSheet()
        }
    }

    // MARK: - Client Header

    private var clientHeader: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.md) {
            // Large avatar
            ClientAvatar(name: client.name, size: 80)

            // Email
            Text(client.email)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)

            // Member since
            Text("Joined \(client.joinedAtFormatted)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            // Active status
            if client.isRecentlyActive {
                HStack(spacing: theme.spacing.xs) {
                    Circle()
                        .fill(theme.colors.success)
                        .frame(width: 8, height: 8)
                    Text("Active")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.success)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.lg)
    }

    // MARK: - Stats Summary

    private var clientStatsSummary: some View {
        let theme = themeManager.current

        return RLCard {
            HStack(spacing: theme.spacing.lg) {
                StatItem(value: "\(client.workoutCount)", label: "Workouts")

                Divider()
                    .frame(height: 32)

                StatItem(value: "\(client.templateCount)", label: "Templates")

                Divider()
                    .frame(height: 32)

                StatItem(value: client.lastActiveFormatted, label: "Last Active")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, theme.spacing.md)
    }

    // MARK: - Assigned Templates Section

    private var assignedTemplatesSection: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text("Assigned Templates")
                    .font(theme.typography.titleSmall)
                    .foregroundStyle(theme.colors.text)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.md)

            if client.templateCount == 0 {
                RLCard {
                    VStack(spacing: theme.spacing.md) {
                        Image(systemName: "doc.on.doc")
                            .font(.title)
                            .foregroundStyle(theme.colors.textTertiary)

                        Text("No templates assigned")
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)

                        ComingSoonButton("Assign Template", icon: "plus", showSheet: $showComingSoonSheet)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, theme.spacing.md)
                }
                .padding(.horizontal, theme.spacing.md)
            } else {
                // Placeholder for assigned templates list (would show TemplateRowView items in v2)
                RLCard {
                    VStack(spacing: theme.spacing.sm) {
                        ForEach(0..<client.templateCount, id: \.self) { index in
                            HStack(spacing: theme.spacing.md) {
                                Image(systemName: "doc.text.fill")
                                    .font(.title3)
                                    .foregroundStyle(theme.colors.accent)
                                    .frame(width: 36, height: 36)
                                    .background(theme.colors.accent.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Template \(index + 1)")
                                        .font(theme.typography.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(theme.colors.text)

                                    Text("Assigned template")
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }

                                Spacer()
                            }

                            if index < client.templateCount - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.md)
            }
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(theme.typography.titleSmall)
                    .foregroundStyle(theme.colors.text)

                Spacer()
            }
            .padding(.horizontal, theme.spacing.md)

            RLCard {
                VStack(spacing: theme.spacing.md) {
                    Image(systemName: "chart.bar")
                        .font(.title)
                        .foregroundStyle(theme.colors.textTertiary)

                    Text("Activity tracking coming soon")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)

                    Text("You'll be able to see your client's workout history and progress here.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.md)
            }
            .padding(.horizontal, theme.spacing.md)
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        let theme = themeManager.current

        return VStack(spacing: theme.spacing.md) {
            ComingSoonButton("Assign Template", icon: "doc.badge.plus", showSheet: $showComingSoonSheet)

            ComingSoonButton("Send Message", icon: "message", showSheet: $showComingSoonSheet)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.md)
    }
}

// MARK: - Helper Extensions

private extension CoachClientPresentable {
    /// Returns true if the client was active within the last 7 days.
    var isRecentlyActive: Bool {
        guard let lastActive = lastActiveAt else { return false }
        return Date().timeIntervalSince(lastActive) < 86400 * 7
    }

    /// Returns a formatted "last active" string for display.
    var lastActiveFormatted: String {
        guard let lastActive = lastActiveAt else { return "Never" }
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(lastActive) {
            return "Today"
        } else if calendar.isDateInYesterday(lastActive) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: lastActive, to: now).day ?? 0
            if days < 7 {
                return "\(days)d ago"
            } else if days < 30 {
                let weeks = days / 7
                return "\(weeks)w ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: lastActive)
            }
        }
    }

    /// Returns a formatted join date string.
    var joinedAtFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: joinedAt)
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    @Environment(ThemeManager.self) private var themeManager

    let value: String
    let label: String

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: 4) {
            Text(value)
                .font(theme.typography.titleSmall)
                .fontWeight(.bold)
                .foregroundStyle(theme.colors.text)

            Text(label)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ClientDetailView") {
    NavigationStack {
        ClientDetailView(client: ClientSummary.sample)
    }
    .environment(ThemeManager())
}

#Preview("ClientDetailView - New Client") {
    NavigationStack {
        ClientDetailView(client: ClientSummary.samples[3]) // Morgan Chen - no activity
    }
    .environment(ThemeManager())
}
#endif
