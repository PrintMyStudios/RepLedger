import SwiftUI

struct DashboardHeaderView: View {
    @Environment(ThemeManager.self) private var themeManager

    // Scaled metric for Dynamic Type support (matches AppTabHeader)
    @ScaledMetric(relativeTo: .body) private var verticalPadding = HeaderMetrics.baseVerticalPadding

    let userName: String

    var body: some View {
        let theme = themeManager.current

        HStack(alignment: .center) {
            // Left: Avatar + Greeting
            HStack(spacing: theme.spacing.sm) {
                // Avatar placeholder
                Circle()
                    .fill(theme.colors.elevated)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    .overlay {
                        Circle()
                            .stroke(theme.colors.border, lineWidth: 2)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(greetingText)
                        .font(theme.header.greetingFont)
                        .tracking(1.0)
                        .textCase(.uppercase)
                        .foregroundStyle(theme.colors.textSecondary)

                    Text("Ready to crush it?")
                        .font(theme.header.dashboardMessageFont)
                        .foregroundStyle(theme.colors.text)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
            }

            Spacer()

            // Right: Notification button
            HeaderActionButton(
                icon: "bell.fill",
                action: {
                    // Notifications action (future)
                },
                accessibilityLabel: "Notifications"
            )
        }
        .padding(.horizontal, DashboardTokens.horizontalGutter)
        .padding(.vertical, verticalPadding)
        // CRITICAL: Extend background into safe area (status bar/notch)
        .background(theme.colors.background, ignoresSafeAreaEdges: .top)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String

        switch hour {
        case 5..<12:
            timeGreeting = "Good Morning"
        case 12..<17:
            timeGreeting = "Good Afternoon"
        default:
            timeGreeting = "Good Evening"
        }

        if userName.isEmpty {
            return timeGreeting
        } else {
            return "\(timeGreeting), \(userName)"
        }
    }
}

#Preview {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack {
            DashboardHeaderView(userName: "Alex")
            Spacer()
        }
    }
    .environment(ThemeManager())
}
