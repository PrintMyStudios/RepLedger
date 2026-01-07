import SwiftUI

/// Notes card for workout detail view with highlight animation support
struct WorkoutDetailNotesCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let notes: String

    /// Binding to trigger highlight animation when scrolled to
    @Binding var isHighlighted: Bool

    var body: some View {
        let theme = themeManager.current

        HStack(alignment: .top, spacing: theme.spacing.md) {
            // Icon
            Circle()
                .fill(theme.colors.elevated)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "note.text")
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.accent)
                }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("WORKOUT NOTES")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(theme.colors.textTertiary)

                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(
                    isHighlighted ? theme.colors.accent : theme.colors.border,
                    lineWidth: isHighlighted ? 2 : 1
                )
                .animation(.easeInOut(duration: 0.3), value: isHighlighted)
        }
        .rlShadow(theme.shadows.card)
        .onChange(of: isHighlighted) { _, newValue in
            // Auto-dismiss highlight after delay
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        isHighlighted = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("WorkoutDetailNotesCard") {
    struct PreviewWrapper: View {
        @State private var isHighlighted = false

        var body: some View {
            ZStack {
                ObsidianTheme().colors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    WorkoutDetailNotesCard(
                        notes: "Felt really strong on the bench today. Shoulder tweak from last week is gone. Might increase weight on Incline next session.",
                        isHighlighted: $isHighlighted
                    )
                    .padding()

                    Button("Trigger Highlight") {
                        withAnimation {
                            isHighlighted = true
                        }
                    }
                    .foregroundStyle(.white)

                    Spacer()
                }
            }
            .environment(ThemeManager())
        }
    }

    return PreviewWrapper()
}
