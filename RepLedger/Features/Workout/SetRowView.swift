import SwiftUI

/// Structured hint for previous set performance (avoids string parsing issues)
struct PreviousSetHint {
    let weight: Double  // Stored in kg
    let reps: Int

    /// Formatted previous display "220 x 5"
    func formatted(unit: WeightUnit) -> String {
        let displayWeight = weight.fromKg(to: unit)
        let weightStr = formatNumber(displayWeight)
        return "\(weightStr) x \(reps)"
    }

    private func formatNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

/// Visual state for a set row
enum SetVisualState {
    case completed  // isCompleted = true
    case active     // First non-completed set
    case pending    // All sets after active
}

/// Row component for displaying and editing a single set within an exercise.
/// Uses a 5-column grid layout: Set | Previous | Weight | Reps | Check
struct SetRowView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    @Bindable var set: SetEntry
    let setNumber: Int
    let visualState: SetVisualState
    let previousHint: PreviousSetHint?
    let onComplete: () -> Void

    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isRepsFocused: Bool

    // Grid column sizes: [36px] [1fr] [1.2fr] [1.2fr] [44px]
    private let gridColumns = [
        GridItem(.fixed(36), spacing: 8),
        GridItem(.flexible(minimum: 50), spacing: 8),
        GridItem(.flexible(minimum: 60), spacing: 8),
        GridItem(.flexible(minimum: 60), spacing: 8),
        GridItem(.fixed(44), spacing: 0)
    ]

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: 0) {
            // Green left border for completed sets
            if visualState == .completed {
                Rectangle()
                    .fill(theme.colors.accent)
                    .frame(width: 4)
            }

            // Main grid content
            LazyVGrid(columns: gridColumns, alignment: .center, spacing: 8) {
                // Set number badge
                setBadge(theme: theme)

                // Previous performance
                previousColumn(theme: theme)

                // Weight input
                weightInput(theme: theme)

                // Reps input
                repsInput(theme: theme)

                // Check button
                checkButton(theme: theme)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, visualState == .active ? theme.spacing.sm + 2 : theme.spacing.sm)
        }
        .background(rowBackground(theme: theme))
        .opacity(visualState == .pending ? 0.6 : 1.0)
        .onAppear { loadValues() }
    }

    // MARK: - Grid Cells

    private func setBadge(theme: any Theme) -> some View {
        ZStack {
            Circle()
                .fill(badgeBackgroundColor(theme: theme))
                .frame(width: 26, height: 26)

            Text("\(setNumber)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(badgeTextColor(theme: theme))
        }
        .accessibilityLabel("Set \(setNumber), \(visualState == .completed ? "completed" : visualState == .active ? "active" : "pending")")
    }

    private func previousColumn(theme: any Theme) -> some View {
        Group {
            if let hint = previousHint {
                Text(hint.formatted(unit: settings.liftingUnit))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.textTertiary)
            } else {
                Text("—")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func weightInput(theme: any Theme) -> some View {
        SetInputField(
            value: $weightText,
            placeholder: previousWeightPlaceholder,
            isActive: visualState == .active,
            isCompleted: visualState == .completed,
            keyboardType: .decimalPad,
            accessibilityLabel: "Weight"
        )
        .focused($isWeightFocused)
        .onChange(of: isWeightFocused) { _, focused in
            if !focused { commitWeight() }
        }
    }

    private func repsInput(theme: any Theme) -> some View {
        SetInputField(
            value: $repsText,
            placeholder: previousRepsPlaceholder,
            isActive: visualState == .active,
            isCompleted: visualState == .completed,
            keyboardType: .numberPad,
            accessibilityLabel: "Reps"
        )
        .focused($isRepsFocused)
        .onChange(of: isRepsFocused) { _, focused in
            if !focused { commitReps() }
        }
    }

    private func checkButton(theme: any Theme) -> some View {
        Button {
            commitWeight()
            commitReps()
            withAnimation(.easeInOut(duration: 0.15)) {
                onComplete()
            }
            hapticFeedback()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(visualState == .completed ? theme.colors.accent : Color.clear)
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            visualState == .completed
                                ? Color.clear
                                : (visualState == .active ? theme.colors.border : theme.colors.border.opacity(0.5)),
                            lineWidth: 2
                        )
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(
                            visualState == .completed
                                ? theme.colors.textOnAccent
                                : (visualState == .active ? theme.colors.textTertiary : Color.clear)
                        )
                )
        }
        .accessibilityLabel(visualState == .completed ? "Completed" : "Mark complete")
        .accessibilityHint("Double tap to toggle")
    }

    // MARK: - Styling Helpers

    private func rowBackground(theme: any Theme) -> Color {
        switch visualState {
        case .completed:
            return theme.colors.accent.opacity(0.05)
        case .active, .pending:
            return Color.clear
        }
    }

    private func badgeBackgroundColor(theme: any Theme) -> Color {
        switch visualState {
        case .completed:
            return theme.colors.accent.opacity(0.2)
        case .active:
            return theme.colors.surface.opacity(0.8)
        case .pending:
            return theme.colors.surface.opacity(0.5)
        }
    }

    private func badgeTextColor(theme: any Theme) -> Color {
        switch visualState {
        case .completed:
            return theme.colors.accent
        case .active:
            return theme.colors.text
        case .pending:
            return theme.colors.textTertiary
        }
    }

    // MARK: - Input Helpers

    private var previousWeightPlaceholder: String {
        guard let hint = previousHint else { return "" }
        let displayWeight = hint.weight.fromKg(to: settings.liftingUnit)
        return formatNumber(displayWeight)
    }

    private var previousRepsPlaceholder: String {
        guard let hint = previousHint else { return "" }
        return "\(hint.reps)"
    }

    private func loadValues() {
        if let weight = set.weight {
            let displayWeight = weight.fromKg(to: settings.liftingUnit)
            weightText = formatNumber(displayWeight)
        }
        if let reps = set.reps {
            repsText = "\(reps)"
        }
    }

    private func commitWeight() {
        if weightText.isEmpty {
            set.weight = nil
        } else if let value = Double(weightText.replacingOccurrences(of: ",", with: ".")) {
            set.weight = value.toKg(from: settings.liftingUnit)
        }
    }

    private func commitReps() {
        if repsText.isEmpty {
            set.reps = nil
        } else if let value = Int(repsText) {
            set.reps = value
        }
    }

    private func formatNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }

    private func hapticFeedback() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Set Input Field

/// Styled input field for weight/reps with visual states
private struct SetInputField: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var value: String
    let placeholder: String
    let isActive: Bool
    let isCompleted: Bool
    let keyboardType: UIKeyboardType
    let accessibilityLabel: String

    var body: some View {
        let theme = themeManager.current

        TextField(placeholder, text: $value)
            .keyboardType(keyboardType)
            .font(.system(size: isActive ? 20 : 18, weight: .bold, design: .rounded))
            .foregroundStyle(value.isEmpty ? theme.colors.textTertiary : theme.colors.text)
            .multilineTextAlignment(.center)
            .frame(height: isActive ? 48 : 40)
            .frame(maxWidth: .infinity)
            .background(theme.colors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: isActive ? 12 : 8))
            .overlay(
                RoundedRectangle(cornerRadius: isActive ? 12 : 8)
                    .strokeBorder(
                        isActive ? theme.colors.border : Color.clear,
                        lineWidth: isActive ? 1.5 : 0
                    )
            )
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(value.isEmpty ? placeholder : value)
    }
}

// MARK: - Column Headers

/// Column headers for the set grid
struct SetColumnHeaders: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: 8) {
            Text("SET")
                .frame(width: 36)

            Text("PREVIOUS")
                .frame(maxWidth: .infinity)

            Text(settings.liftingUnit.abbreviation.uppercased())
                .frame(maxWidth: .infinity)

            Text("REPS")
                .frame(maxWidth: .infinity)

            Image(systemName: "checkmark")
                .frame(width: 44)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(theme.colors.textTertiary)
        .tracking(0.5)
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .overlay(alignment: .bottom) {
            // Dashed divider
            Rectangle()
                .fill(theme.colors.divider)
                .frame(height: 1)
                .mask(
                    HStack(spacing: 4) {
                        ForEach(0..<50, id: \.self) { _ in
                            Rectangle()
                                .frame(width: 6, height: 1)
                        }
                    }
                )
        }
    }
}

// MARK: - Preview

#Preview("SetRowView - States") {
    VStack(spacing: 0) {
        SetColumnHeaders()

        // Completed set
        SetRowView(
            set: SetEntry(weight: 102.06, reps: 5, isCompleted: true), // 225 lbs in kg
            setNumber: 1,
            visualState: .completed,
            previousHint: PreviousSetHint(weight: 99.79, reps: 5), // 220 lbs
            onComplete: {}
        )

        // Active set
        SetRowView(
            set: SetEntry(weight: 104.33, reps: 5), // 230 lbs
            setNumber: 2,
            visualState: .active,
            previousHint: PreviousSetHint(weight: 102.06, reps: 5),
            onComplete: {}
        )

        // Pending set
        SetRowView(
            set: SetEntry(weight: nil, reps: nil),
            setNumber: 3,
            visualState: .pending,
            previousHint: PreviousSetHint(weight: 102.06, reps: 5),
            onComplete: {}
        )
    }
    .background(ObsidianTheme().colors.completedSetTint)
    .environment(ThemeManager())
}
