import SwiftUI

/// Template row view for the Start screen template list.
struct StartTemplateRowView: View {
    @Environment(ThemeManager.self) private var themeManager

    let template: Template
    let lastWorkoutDuration: TimeInterval?
    let onTap: () -> Void

    private let minDurationToShow: TimeInterval = 300 // 5 minutes

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            HStack(spacing: 12) {
                // Template monogram
                templateMonogram(theme: theme)

                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(theme.colors.text)
                        .lineLimit(1)

                    Text(metaText)
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(14)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(template.name), \(template.orderedExerciseIds.count) exercises")
    }

    // MARK: - Subviews

    private func templateMonogram(theme: any Theme) -> some View {
        let letter = String(template.name.prefix(1)).uppercased()

        return Text(letter)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(theme.colors.accent)
            .frame(width: 40, height: 40)
            .background(theme.colors.accent.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
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
}

// MARK: - Preview

#Preview("StartTemplateRowView") {
    ZStack {
        ObsidianTheme().colors.background.ignoresSafeArea()

        VStack(spacing: 10) {
            StartTemplateRowView(
                template: Template(name: "Full Body A", lastUsedAt: Date()),
                lastWorkoutDuration: 3600,
                onTap: { print("Tapped") }
            )

            StartTemplateRowView(
                template: Template(name: "Leg Hypertrophy", lastUsedAt: Date().addingTimeInterval(-86400)),
                lastWorkoutDuration: 2700,
                onTap: { print("Tapped") }
            )

            StartTemplateRowView(
                template: Template(name: "Quick Upper", lastUsedAt: nil),
                lastWorkoutDuration: nil,
                onTap: { print("Tapped") }
            )
        }
        .padding(.horizontal, 20)
    }
    .environment(ThemeManager())
}
