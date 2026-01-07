import SwiftUI

/// Redesigned workout header with centered layout, live timer, and editable title.
struct WorkoutHeaderView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.workoutManager) private var workoutManager

    let workout: Workout
    let onClose: () -> Void
    let onFinish: () -> Void

    @State private var showTitleEditor = false
    @State private var editedTitle = ""
    @State private var isPulsing = true
    @State private var currentTime = Date()

    // Timer to update the duration display
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        let theme = themeManager.current

        ZStack {
            // Centered title and timer - truly centered on screen
            centerContent(theme: theme)

            // Left and right buttons overlaid at edges
            HStack {
                closeButton(theme: theme)
                Spacer()
                finishButton(theme: theme)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(
            theme.colors.background.opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .alert("Edit Workout Name", isPresented: $showTitleEditor) {
            TextField("Workout name", text: $editedTitle)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                workoutManager.updateWorkoutTitle(editedTitle)
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    // MARK: - Close Button

    private func closeButton(theme: any Theme) -> some View {
        Button {
            onClose()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: 40, height: 40)
                .background(theme.colors.surface)
                .clipShape(Circle())
        }
    }

    // MARK: - Center Content

    private func centerContent(theme: any Theme) -> some View {
        VStack(spacing: 4) {
            // Title with edit icon - title centered, pencil overlaid after
            Button {
                editedTitle = workout.title
                showTitleEditor = true
            } label: {
                Text(workout.title)
                    .font(theme.typography.bodyLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(theme.colors.textSecondary)
                            .offset(x: 18)
                    }
            }

            // Live timer with pulsing dot
            HStack(spacing: 8) {
                // Pulsing green dot
                Circle()
                    .fill(theme.colors.accent)
                    .frame(width: 8, height: 8)
                    .shadow(color: theme.colors.accent.opacity(0.8), radius: 4)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                    .onAppear { isPulsing = true }

                // Timer display - uses currentTime to trigger re-renders
                Text(formattedDuration)
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundStyle(theme.colors.accent)
                    .tracking(0.5)
            }
        }
    }

    // MARK: - Computed Duration

    /// Format the workout duration using currentTime to ensure live updates
    private var formattedDuration: String {
        let totalSeconds = Int(max(0, currentTime.timeIntervalSince(workout.startedAt)))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Finish Button

    private func finishButton(theme: any Theme) -> some View {
        Button {
            onFinish()
        } label: {
            Text("FINISH")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(theme.colors.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(theme.colors.accent.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(theme.colors.accent.opacity(0.2), lineWidth: 1)
                )
        }
        .disabled(workout.completedSetCount == 0)
        .opacity(workout.completedSetCount == 0 ? 0.5 : 1.0)
    }
}

// MARK: - Preview

#Preview("WorkoutHeaderView") {
    VStack {
        WorkoutHeaderView(
            workout: Workout(title: "Leg Day - Heavy"),
            onClose: { },
            onFinish: { }
        )

        Spacer()
    }
    .background(ObsidianTheme().colors.background)
    .environment(ThemeManager())
}
