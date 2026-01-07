import SwiftUI

/// Featured template card for the 2-up row on the Start screen.
struct TemplateFeaturedCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let template: Template
    let lastWorkoutDuration: TimeInterval?
    let onTap: () -> Void

    private let minDurationToShow: TimeInterval = 300 // 5 minutes

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Template monogram
                templateMonogram(theme: theme)

                Spacer()

                // Template name
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                // Meta: exercise count + optional duration
                Text(metaText)
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)

                // Last used info
                if let lastUsed = template.lastUsedAt {
                    Text(formatLastUsed(lastUsed))
                        .font(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .frame(height: 140)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("\(template.name), \(template.orderedExerciseIds.count) exercises")
    }

    // MARK: - Subviews

    private func templateMonogram(theme: any Theme) -> some View {
        let letter = String(template.name.prefix(1)).uppercased()

        return Text(letter)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(theme.colors.accent)
            .frame(width: 32, height: 32)
            .background(theme.colors.accent.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Computed Properties

    private var metaText: String {
        let exerciseCount = template.orderedExerciseIds.count
        let exerciseText = "\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"

        // Only show duration if >= 5 minutes
        if let duration = lastWorkoutDuration, duration >= minDurationToShow {
            let minutes = Int(duration / 60)
            if minutes >= 60 {
                let hours = minutes / 60
                let mins = minutes % 60
                return "\(exerciseText) • Last: \(hours)h \(mins)m"
            }
            return "\(exerciseText) • Last: \(minutes)m"
        }

        return exerciseText
    }

    private func formatLastUsed(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Last used today"
        } else if calendar.isDateInYesterday(date) {
            return "Last used yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if days < 7 {
                return "Last used \(days)d ago"
            } else if days < 30 {
                let weeks = days / 7
                return "Last used \(weeks)w ago"
            } else {
                return "Last used \(date.formatted(.dateTime.month(.abbreviated).day()))"
            }
        }
    }
}

// MARK: - Preview

#Preview("TemplateFeaturedCard") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        HStack(spacing: 12) {
            TemplateFeaturedCard(
                template: Template(name: "Push Day", lastUsedAt: Date().addingTimeInterval(-86400)),
                lastWorkoutDuration: 3600, // 60 minutes
                onTap: { print("Tapped Push Day") }
            )

            TemplateFeaturedCard(
                template: Template(name: "Full Body A", lastUsedAt: Date().addingTimeInterval(-259200)),
                lastWorkoutDuration: nil,
                onTap: { print("Tapped Full Body") }
            )
        }
        .padding(.horizontal, 20)
    }
    .environment(ThemeManager())
}
