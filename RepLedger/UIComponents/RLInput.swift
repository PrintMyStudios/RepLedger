import SwiftUI

/// Input field type for different keyboard and validation behaviors
enum RLInputType {
    case text
    case number
    case decimal
    case weight    // Shows appropriate keyboard for weight entry
    case reps      // Integer input for reps

    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .number, .reps: return .numberPad
        case .decimal, .weight: return .decimalPad
        }
    }
}

/// A themed text input field with label and validation support.
struct RLInput: View {
    @Environment(ThemeManager.self) private var themeManager

    let label: String
    let placeholder: String
    let type: RLInputType
    @Binding var text: String
    var errorMessage: String?
    var helpText: String?
    var suffix: String?

    init(
        _ label: String,
        placeholder: String = "",
        type: RLInputType = .text,
        text: Binding<String>,
        errorMessage: String? = nil,
        helpText: String? = nil,
        suffix: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self.type = type
        self._text = text
        self.errorMessage = errorMessage
        self.helpText = helpText
        self.suffix = suffix
    }

    var body: some View {
        let theme = themeManager.current
        let hasError = errorMessage != nil

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Label
            Text(label)
                .font(theme.typography.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)

            // Input field
            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(type.keyboardType)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.text)

                if let suffix = suffix {
                    Text(suffix)
                        .font(theme.typography.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm + 4)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.small)
                    .stroke(
                        hasError ? theme.colors.error : theme.colors.border,
                        lineWidth: 1
                    )
            }

            // Error or help text
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(theme.typography.captionSmall)
                    .foregroundStyle(theme.colors.error)
            } else if let helpText = helpText {
                Text(helpText)
                    .font(theme.typography.captionSmall)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(text)
        .accessibilityHint(helpText ?? "")
    }
}

// MARK: - Numeric Input Variant

struct RLNumericInput: View {
    @Environment(ThemeManager.self) private var themeManager

    let label: String
    @Binding var value: Double?
    var suffix: String?
    var placeholder: String

    @State private var textValue: String = ""

    init(
        _ label: String,
        value: Binding<Double?>,
        suffix: String? = nil,
        placeholder: String = "0"
    ) {
        self.label = label
        self._value = value
        self.suffix = suffix
        self.placeholder = placeholder
    }

    var body: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(label)
                .font(theme.typography.bodySmall)
                .foregroundStyle(theme.colors.textSecondary)

            HStack {
                TextField(placeholder, text: $textValue)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.colors.text)
                    .onChange(of: textValue) { _, newValue in
                        // Allow empty string
                        if newValue.isEmpty {
                            value = nil
                            return
                        }
                        // Parse and update value
                        if let parsed = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                            value = parsed
                        }
                    }
                    .onAppear {
                        if let value = value {
                            textValue = formatNumber(value)
                        }
                    }

                if let suffix = suffix {
                    Text(suffix)
                        .font(theme.typography.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm + 4)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.small)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
        }
    }

    private func formatNumber(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Preview

#Preview("RLInput") {
    VStack(spacing: 24) {
        RLInput(
            "Exercise Name",
            placeholder: "Enter exercise name",
            text: .constant("Bench Press")
        )

        RLInput(
            "Weight",
            placeholder: "0",
            type: .weight,
            text: .constant("100"),
            suffix: "kg"
        )

        RLInput(
            "Email",
            placeholder: "you@example.com",
            text: .constant("invalid"),
            errorMessage: "Please enter a valid email"
        )

        RLInput(
            "Notes",
            placeholder: "Add workout notes...",
            text: .constant(""),
            helpText: "Optional"
        )
    }
    .padding()
    .background(Color(hex: "0A0A0C"))
    .environment(ThemeManager())
}
