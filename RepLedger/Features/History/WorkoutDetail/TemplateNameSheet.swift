import SwiftUI

/// Sheet for entering a template name when saving workout as template
struct TemplateNameSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var templateName: String
    @FocusState private var isNameFocused: Bool

    let workoutTitle: String
    let onSave: (String) -> Void

    init(workoutTitle: String, onSave: @escaping (String) -> Void) {
        self.workoutTitle = workoutTitle
        self.onSave = onSave
        // Pre-fill with workout title
        _templateName = State(initialValue: workoutTitle)
    }

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            VStack(spacing: theme.spacing.lg) {
                // Description
                Text("Create a template from this workout's exercises. You can use it to quickly start similar workouts.")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, theme.spacing.md)

                // Name input
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text("TEMPLATE NAME")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(theme.colors.textTertiary)

                    TextField("Enter name", text: $templateName)
                        .font(.system(size: 16))
                        .padding(theme.spacing.md)
                        .background(theme.colors.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
                        .overlay {
                            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                                .stroke(
                                    isNameFocused ? theme.colors.accent : theme.colors.border,
                                    lineWidth: 1
                                )
                        }
                        .focused($isNameFocused)
                }
                .padding(.horizontal, theme.spacing.md)

                Spacer()

                // Save button
                Button {
                    onSave(templateName.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                } label: {
                    Text("Save Template")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canSave ? Color.black : theme.colors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.md)
                        .background(canSave ? theme.colors.accent : theme.colors.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
                }
                .disabled(!canSave)
                .padding(.horizontal, theme.spacing.md)
                .padding(.bottom, theme.spacing.md)
            }
            .padding(.top, theme.spacing.lg)
            .background(theme.colors.background)
            .navigationTitle("Save as Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(theme.colors.text)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            // Focus the text field after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }

    private var canSave: Bool {
        !templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Preview

#Preview("TemplateNameSheet") {
    struct PreviewWrapper: View {
        @State private var showSheet = true

        var body: some View {
            let theme = ObsidianTheme()
            ZStack {
                theme.colors.background.ignoresSafeArea()
                Button("Show Sheet") {
                    showSheet = true
                }
                .foregroundStyle(theme.colors.text)
            }
            .sheet(isPresented: $showSheet) {
                TemplateNameSheet(
                    workoutTitle: "Hypertrophy Push",
                    onSave: { name in
                        print("Saving template: \(name)")
                    }
                )
                .environment(ThemeManager())
            }
        }
    }

    return PreviewWrapper()
        .environment(ThemeManager())
}
