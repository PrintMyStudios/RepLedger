import SwiftUI

/// Row component for displaying a template in a list.
struct TemplateRowView: View {
    @Environment(ThemeManager.self) private var themeManager

    let template: Template
    let exerciseCount: Int

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            // Template icon
            Image(systemName: "doc.text.fill")
                .font(.title2)
                .foregroundStyle(theme.colors.accent)
                .frame(width: 40, height: 40)
                .background(theme.colors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))

            // Template info
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                HStack(spacing: theme.spacing.sm) {
                    Label("\(exerciseCount)", systemImage: "dumbbell.fill")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)

                    if let lastUsed = template.lastUsedAt {
                        Text("•")
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(formatLastUsed(lastUsed))
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(template.name), \(exerciseCount) exercises")
    }

    private func formatLastUsed(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if days < 7 {
                return "\(days)d ago"
            } else if days < 30 {
                let weeks = days / 7
                return "\(weeks)w ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
        }
    }
}

// MARK: - Preview

#Preview("TemplateRowView") {
    VStack(spacing: 12) {
        TemplateRowView(
            template: Template(name: "Push Day", lastUsedAt: Date()),
            exerciseCount: 5
        )

        TemplateRowView(
            template: Template(name: "Pull Day", lastUsedAt: Date().addingTimeInterval(-86400 * 3)),
            exerciseCount: 6
        )

        TemplateRowView(
            template: Template(name: "Leg Day"),
            exerciseCount: 8
        )
    }
    .padding()
    .background(ObsidianTheme().colors.surfaceDeep)
    .environment(ThemeManager())
}
