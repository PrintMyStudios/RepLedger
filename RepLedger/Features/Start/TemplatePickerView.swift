import SwiftUI
import SwiftData

/// Sheet view for selecting a template to start a workout.
struct TemplatePickerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Template.lastUsedAt, order: .reverse) private var templates: [Template]

    let onSelect: (Template) -> Void

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            Group {
                if templates.isEmpty {
                    VStack(spacing: theme.spacing.lg) {
                        RLEmptyState(
                            icon: "doc.text.fill",
                            title: "No Templates",
                            subtitle: "Create a template to quickly start workouts with your favorite exercises."
                        )

                        NavigationLink {
                            TemplateEditorView(mode: .create)
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Create Template")
                            }
                            .font(theme.typography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(theme.colors.textOnAccent)
                            .padding(.vertical, theme.spacing.sm + 4)
                            .padding(.horizontal, theme.spacing.lg)
                            .background(theme.colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: theme.spacing.sm) {
                            ForEach(templates) { template in
                                Button {
                                    onSelect(template)
                                    dismiss()
                                } label: {
                                    TemplateRowView(
                                        template: template,
                                        exerciseCount: template.orderedExerciseIds.count
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(theme.spacing.md)
                    }
                }
            }
            .background(theme.colors.background)
            .navigationTitle("Choose Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if !templates.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            TemplateEditorView(mode: .create)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("TemplatePickerView") {
    TemplatePickerView { template in
        print("Selected: \(template.name)")
    }
    .environment(ThemeManager())
}
