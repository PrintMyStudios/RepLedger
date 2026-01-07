import SwiftUI

/// Glassmorphic header for workout detail view
/// Modern frosted glass design with native iOS navigation feel
struct WorkoutDetailHeader: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    let title: String
    let date: Date
    let duration: TimeInterval

    var onRepeat: () -> Void
    var onSaveAsTemplate: () -> Void
    var onDelete: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.sm) {
            // Glass navigation bar
            glassNavBar

            // Metadata pills
            metadataPills
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.xs)
    }

    // MARK: - Glass Navigation Bar

    private var glassNavBar: some View {
        let theme = themeManager.current

        return HStack(spacing: 0) {
            // Back button
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(theme.colors.text)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(width: 44, height: 44)

            Spacer()

            // Centered title
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(theme.colors.text)
                .lineLimit(1)

            Spacer()

            // Menu button
            Menu {
                Button {
                    onRepeat()
                } label: {
                    Label("Repeat Workout", systemImage: "arrow.counterclockwise")
                }

                Button {
                    onSaveAsTemplate()
                } label: {
                    Label("Save as Template", systemImage: "doc.badge.plus")
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete Workout", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(theme.colors.text)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    // MARK: - Metadata Pills

    private var metadataPills: some View {
        let theme = themeManager.current

        return HStack(spacing: theme.spacing.sm) {
            // Date pill
            metadataPill(
                icon: "calendar",
                text: Self.dateFormatter.string(from: date)
            )

            // Duration pill
            metadataPill(
                icon: "clock",
                text: formatDuration(duration)
            )

            // Time pill
            metadataPill(
                icon: "sun.max",
                text: Self.timeFormatter.string(from: date)
            )
        }
    }

    private func metadataPill(icon: String, text: String) -> some View {
        let theme = themeManager.current

        return HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(theme.colors.textTertiary)

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(theme.colors.surface.opacity(0.6))
                .overlay {
                    Capsule()
                        .stroke(theme.colors.border.opacity(0.3), lineWidth: 0.5)
                }
        )
    }

    // MARK: - Helpers

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Formatters

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}

// MARK: - Preview

#Preview("WorkoutDetailHeader") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack {
            WorkoutDetailHeader(
                title: "Hypertrophy Push",
                date: Date(),
                duration: 4500,
                onRepeat: {},
                onSaveAsTemplate: {},
                onDelete: {}
            )
            Spacer()
        }
        .padding(.top, 60)
    }
    .environment(ThemeManager())
}

#Preview("WorkoutDetailHeader - Long Title") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()
        VStack {
            WorkoutDetailHeader(
                title: "Upper Body Power & Hypertrophy Day",
                date: Date().addingTimeInterval(-86400 * 3),
                duration: 7200,
                onRepeat: {},
                onSaveAsTemplate: {},
                onDelete: {}
            )
            Spacer()
        }
        .padding(.top, 60)
    }
    .environment(ThemeManager())
}
