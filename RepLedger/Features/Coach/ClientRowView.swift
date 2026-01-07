import SwiftUI

/// Row component for displaying a client in the Coach client list.
struct ClientRowView: View {
    @Environment(ThemeManager.self) private var themeManager

    let client: any CoachClientPresentable

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            // Avatar (initials badge)
            ClientAvatar(name: client.name)

            // Client info
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                HStack(spacing: theme.spacing.sm) {
                    if client.workoutCount > 0 {
                        Label("\(client.workoutCount) workouts", systemImage: "figure.strengthtraining.traditional")
                    } else {
                        Text("New client")
                    }

                    if client.lastActiveAt != nil {
                        Text("•")
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(client.lastActiveFormatted)
                    }
                }
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()

            // Active indicator (within 7 days)
            if client.isRecentlyActive {
                Circle()
                    .fill(theme.colors.success)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("Active in last 7 days")
            }

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(client.name), \(client.workoutCount) workouts")
    }
}

// MARK: - Helper Extensions

private extension CoachClientPresentable {
    /// Returns the client's initials (up to 2 characters) for avatar display.
    var initials: String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined().uppercased()
    }

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
}

// MARK: - Client Avatar

/// Circular avatar showing client initials.
struct ClientAvatar: View {
    @Environment(ThemeManager.self) private var themeManager

    let name: String
    var size: CGFloat = 44

    var body: some View {
        let theme = themeManager.current

        Text(initials)
            .font(size > 60 ? theme.typography.titleMedium : theme.typography.body)
            .fontWeight(.semibold)
            .foregroundStyle(theme.colors.accent)
            .frame(width: size, height: size)
            .background(theme.colors.accent.opacity(0.15))
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private var initials: String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined().uppercased()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("ClientRowView") {
    VStack(spacing: 12) {
        ForEach(ClientSummary.samples) { client in
            ClientRowView(client: client)
        }
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}

#Preview("ClientAvatar Sizes") {
    HStack(spacing: 16) {
        ClientAvatar(name: "Alex Johnson", size: 32)
        ClientAvatar(name: "Alex Johnson", size: 44)
        ClientAvatar(name: "Alex Johnson", size: 64)
        ClientAvatar(name: "Alex Johnson", size: 80)
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
#endif
