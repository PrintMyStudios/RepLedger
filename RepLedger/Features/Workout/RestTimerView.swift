import SwiftUI

/// Floating rest timer pill overlay shown during active workouts.
struct RestTimerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.workoutManager) private var workoutManager

    var body: some View {
        let theme = themeManager.current

        if let timer = workoutManager.restTimer {
            HStack(spacing: theme.spacing.md) {
                // Timer display
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: timer.isComplete ? "checkmark.circle.fill" : "timer")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(timer.isComplete ? theme.colors.success : theme.colors.accent)

                    Text(timer.formattedTime)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(timer.isComplete ? theme.colors.success : theme.colors.text)
                        .contentTransition(.numericText())
                }

                Spacer()

                // Controls
                HStack(spacing: theme.spacing.sm) {
                    // +15s button
                    TimerControlButton(icon: "plus", label: "+15s") {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            workoutManager.addTime(15)
                        }
                        hapticFeedback(.light)
                    }

                    // Pause/Resume button
                    TimerControlButton(
                        icon: timer.isRunning ? "pause.fill" : "play.fill",
                        label: timer.isRunning ? "Pause" : "Resume"
                    ) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if timer.isRunning {
                                workoutManager.pauseTimer()
                            } else {
                                workoutManager.resumeTimer()
                            }
                        }
                        hapticFeedback(.light)
                    }

                    // Dismiss button
                    TimerControlButton(icon: "xmark", label: "Dismiss") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            workoutManager.dismissTimer()
                        }
                        hapticFeedback(.light)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background {
                RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                    .fill(theme.colors.elevated)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            }
            .overlay {
                // Progress indicator
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                        .fill(theme.colors.accent.opacity(0.2))
                        .frame(width: geometry.size.width * timer.progress)
                        .animation(.linear(duration: 1), value: timer.progress)
                }
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
                .allowsHitTesting(false)
            }
            .padding(.horizontal, theme.spacing.md)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onChange(of: timer.isComplete) { _, isComplete in
                if isComplete {
                    hapticFeedback(.success)
                }
            }
        }
    }

    private func hapticFeedback(_ style: HapticStyle) {
        #if os(iOS)
        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        #endif
    }

    private enum HapticStyle {
        case light
        case success
    }
}

/// Small control button for timer actions
private struct TimerControlButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.colors.text)
                .frame(width: 36, height: 36)
                .background(theme.colors.surface)
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
    }
}

// MARK: - Timer Overlay Container

/// Container view that positions the rest timer at the bottom of the screen.
/// Wrap your main content in this view to add the timer overlay.
struct RestTimerOverlay<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.workoutManager) private var workoutManager

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let theme = themeManager.current

        ZStack(alignment: .bottom) {
            content

            if workoutManager.isTimerActive {
                RestTimerView()
                    .padding(.bottom, theme.spacing.md)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: workoutManager.isTimerActive)
    }
}

// MARK: - Preview

#Preview("RestTimerView") {
    struct PreviewWrapper: View {
        @State private var workoutManager = WorkoutManager()

        var body: some View {
            VStack {
                Spacer()

                Button("Start 90s Timer") {
                    workoutManager.startTimer(duration: 90)
                }

                Button("Start 10s Timer") {
                    workoutManager.startTimer(duration: 10)
                }

                Spacer()

                RestTimerView()
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ObsidianTheme().colors.surfaceDeep)
            .environment(\.workoutManager, workoutManager)
            .environment(ThemeManager())
        }
    }

    return PreviewWrapper()
}
