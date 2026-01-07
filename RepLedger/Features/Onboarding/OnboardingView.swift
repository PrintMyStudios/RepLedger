import SwiftUI

/// Main onboarding container with paged navigation
struct OnboardingView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    @State private var currentPage = 0

    private let totalPages = 6

    var body: some View {
        let theme = themeManager.current

        ZStack {
            // Background
            theme.colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? theme.colors.accent : theme.colors.divider)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                .padding(.top, theme.spacing.lg)
                .padding(.bottom, theme.spacing.md)

                // Page content
                TabView(selection: $currentPage) {
                    OnboardingWelcomePage(onContinue: nextPage)
                        .tag(0)

                    OnboardingNamePage(onContinue: nextPage)
                        .tag(1)

                    OnboardingSessionsGoalPage(onContinue: nextPage)
                        .tag(2)

                    OnboardingLiftingUnitsPage(onContinue: nextPage)
                        .tag(3)

                    OnboardingBodyweightPage(onContinue: nextPage)
                        .tag(4)

                    OnboardingRestTimerPage(onComplete: completeOnboarding)
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
            }
        }
    }

    private func nextPage() {
        withAnimation {
            if currentPage < totalPages - 1 {
                currentPage += 1
            }
        }
    }

    private func completeOnboarding() {
        settings.hasCompletedOnboarding = true
    }
}

// MARK: - Welcome Page

struct OnboardingWelcomePage: View {
    @Environment(ThemeManager.self) private var themeManager

    let onContinue: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 80))
                .foregroundStyle(theme.colors.accent)
                .accessibilityHidden(true)

            // Title & subtitle
            VStack(spacing: theme.spacing.sm) {
                Text("RepLedger")
                    .font(theme.typography.titleLarge)
                    .foregroundStyle(theme.colors.text)

                Text("Track your training.\nBeat your last session.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Continue button
            RLButton("Get Started", icon: "arrow.right", action: onContinue)
                .padding(.horizontal, theme.spacing.lg)

            Spacer()
                .frame(height: theme.spacing.xxl)
        }
        .padding(theme.spacing.lg)
    }
}

// MARK: - Name Page

struct OnboardingNamePage: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    @State private var nameText: String = ""

    let onContinue: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Header
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.accent)

                Text("What's your name?")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("We'll use this to personalize\nyour experience")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Name input
            VStack(spacing: theme.spacing.sm) {
                TextField("Enter your name", text: $nameText)
                    .font(theme.typography.bodyLarge)
                    .foregroundStyle(theme.colors.text)
                    .padding(theme.spacing.md)
                    .background(theme.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                            .stroke(theme.colors.border, lineWidth: 1)
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
            }
            .padding(.horizontal, theme.spacing.lg)

            Spacer()

            VStack(spacing: theme.spacing.md) {
                RLButton("Continue", action: {
                    settings.userName = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
                    onContinue()
                })

                Button("Skip for now") {
                    onContinue()
                }
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
            }
            .padding(.horizontal, theme.spacing.lg)

            Spacer()
                .frame(height: theme.spacing.xxl)
        }
        .padding(theme.spacing.lg)
        .onAppear {
            nameText = settings.userName
        }
    }
}

// MARK: - Sessions Goal Page

struct OnboardingSessionsGoalPage: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let onContinue: () -> Void

    private let goalOptions = [3, 4, 5, 6, 7]

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Header
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.accent)

                Text("Weekly Goal")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("How many workouts do you\nwant to complete each week?")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Options
            VStack(spacing: theme.spacing.md) {
                ForEach(goalOptions, id: \.self) { goal in
                    SessionsGoalOptionButton(
                        goal: goal,
                        isSelected: settings.weeklySessionsGoal == goal
                    ) {
                        settings.weeklySessionsGoal = goal
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)

            Spacer()

            RLButton("Continue", action: onContinue)
                .padding(.horizontal, theme.spacing.lg)

            Spacer()
                .frame(height: theme.spacing.xxl)
        }
        .padding(theme.spacing.lg)
    }
}

struct SessionsGoalOptionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let goal: Int
    let isSelected: Bool
    let action: () -> Void

    private var subtitle: String {
        switch goal {
        case 3: return "Light training"
        case 4: return "Recommended"
        case 5: return "Active lifestyle"
        case 6: return "Serious athlete"
        case 7: return "Daily training"
        default: return ""
        }
    }

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(goal) workouts")
                        .font(theme.typography.bodyLarge)
                        .foregroundStyle(theme.colors.text)

                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(theme.colors.accent)
                } else {
                    Circle()
                        .strokeBorder(theme.colors.border, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(theme.spacing.md)
            .background(isSelected ? theme.colors.accent.opacity(0.1) : theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(isSelected ? theme.colors.accent : theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Lifting Units Page

struct OnboardingLiftingUnitsPage: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let onContinue: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Header
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "scalemass.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.accent)

                Text("Lifting Units")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("Choose how you measure weight\nfor exercises")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Options
            VStack(spacing: theme.spacing.md) {
                ForEach(WeightUnit.allCases) { unit in
                    UnitOptionButton(
                        title: unit.displayName,
                        subtitle: "e.g., 100 \(unit.abbreviation)",
                        isSelected: settings.liftingUnit == unit
                    ) {
                        settings.liftingUnit = unit
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)

            Spacer()

            RLButton("Continue", action: onContinue)
                .padding(.horizontal, theme.spacing.lg)

            Spacer()
                .frame(height: theme.spacing.xxl)
        }
        .padding(theme.spacing.lg)
    }
}

// MARK: - Bodyweight Display Page

struct OnboardingBodyweightPage: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let onContinue: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Header
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.accent)

                Text("Bodyweight Display")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("How should we show your\nbodyweight measurements?")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Options
            VStack(spacing: theme.spacing.md) {
                ForEach(BodyweightUnit.allCases) { unit in
                    UnitOptionButton(
                        title: unit.displayName,
                        subtitle: exampleWeight(for: unit),
                        isSelected: settings.bodyweightUnit == unit
                    ) {
                        settings.bodyweightUnit = unit
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)

            Spacer()

            RLButton("Continue", action: onContinue)
                .padding(.horizontal, theme.spacing.lg)

            Spacer()
                .frame(height: theme.spacing.xxl)
        }
        .padding(theme.spacing.lg)
    }

    private func exampleWeight(for unit: BodyweightUnit) -> String {
        let exampleKg = 75.0
        return "e.g., \(unit.format(exampleKg))"
    }
}

// MARK: - Rest Timer Page (Final Page)

struct OnboardingRestTimerPage: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let onComplete: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.xl) {
            Spacer()

            // Header
            VStack(spacing: theme.spacing.sm) {
                Image(systemName: "timer")
                    .font(.system(size: 48))
                    .foregroundStyle(theme.colors.accent)

                Text("Rest Timer")
                    .font(theme.typography.titleMedium)
                    .foregroundStyle(theme.colors.text)

                Text("Set your default rest time\nbetween sets")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Timer presets
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: theme.spacing.md) {
                ForEach(UserSettings.restTimerPresets, id: \.self) { seconds in
                    TimerPresetButton(
                        seconds: seconds,
                        isSelected: settings.restTimerDuration == seconds
                    ) {
                        settings.restTimerDuration = seconds
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)

            // Auto-start toggle
            Toggle(isOn: Binding(
                get: { settings.restTimerAutoStart },
                set: { settings.restTimerAutoStart = $0 }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Auto-start timer")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.text)
                    Text("Start timer after completing a set")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .tint(theme.colors.accent)
            .padding(theme.spacing.md)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .padding(.horizontal, theme.spacing.lg)

            Spacer()

            RLButton("Start Training", icon: "arrow.right", action: onComplete)
                .padding(.horizontal, theme.spacing.lg)

            Spacer()
                .frame(height: theme.spacing.xxl)
        }
        .padding(theme.spacing.lg)
    }
}

// MARK: - Helper Components

struct UnitOptionButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(theme.typography.bodyLarge)
                        .foregroundStyle(theme.colors.text)

                    Text(subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(theme.colors.accent)
                } else {
                    Circle()
                        .strokeBorder(theme.colors.border, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(theme.spacing.md)
            .background(isSelected ? theme.colors.accent.opacity(0.1) : theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                    .stroke(isSelected ? theme.colors.accent : theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct TimerPresetButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let seconds: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            Text(formatDuration(seconds))
                .font(theme.typography.bodyLarge)
                .foregroundStyle(isSelected ? theme.colors.textOnAccent : theme.colors.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.md)
                .background(isSelected ? theme.colors.accent : theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
                .overlay {
                    if !isSelected {
                        RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                            .stroke(theme.colors.border, lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(formatDuration(seconds)) rest")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        if minutes > 0 && secs > 0 {
            return "\(minutes)m \(secs)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(secs)s"
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView()
        .environment(ThemeManager())
}
