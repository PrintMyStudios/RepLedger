import SwiftUI
import SwiftData

/// Editor view for creating and editing workout templates.
struct TemplateEditorView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var allExercises: [Exercise]

    let mode: Mode

    @State private var templateName: String = ""
    @State private var exerciseIds: [UUID] = []
    @State private var showExercisePicker = false
    @State private var showDiscardAlert = false

    enum Mode {
        case create
        case edit(Template)

        var isEditing: Bool {
            if case .edit = self { return true }
            return false
        }

        var title: String {
            switch self {
            case .create: return "New Template"
            case .edit: return "Edit Template"
            }
        }
    }

    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle(mode.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .sheet(isPresented: $showExercisePicker) {
                    ExercisePickerView(
                        onSelect: { exercise in
                            exerciseIds.append(exercise.id)
                        },
                        excludedExerciseIds: Set(exerciseIds)
                    )
                }
                .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                    Button("Keep Editing", role: .cancel) { }
                    Button("Discard", role: .destructive) { dismiss() }
                } message: {
                    Text("You have unsaved changes. Are you sure you want to discard them?")
                }
                .onAppear { loadTemplate() }
        }
    }

    // MARK: - Content Views

    @ViewBuilder
    private var mainContent: some View {
        let theme = themeManager.current

        ScrollView {
            VStack(spacing: theme.spacing.lg) {
                nameInputSection
                exercisesSection
            }
            .padding(.vertical, theme.spacing.md)
        }
        .background(theme.colors.background)
    }

    @ViewBuilder
    private var nameInputSection: some View {
        let theme = themeManager.current

        RLInput(
            "Template Name",
            placeholder: "e.g., Push Day, Upper Body",
            text: $templateName
        )
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var exercisesSection: some View {
        let theme = themeManager.current

        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            exercisesSectionHeader

            if exerciseIds.isEmpty {
                exercisesEmptyState
            } else {
                exercisesList
                addExerciseButton
            }
        }
    }

    @ViewBuilder
    private var exercisesSectionHeader: some View {
        let theme = themeManager.current

        HStack {
            Text("Exercises")
                .font(theme.typography.titleSmall)
                .foregroundStyle(theme.colors.text)

            Spacer()

            if !exerciseIds.isEmpty {
                Text("\(exerciseIds.count)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.colors.surface)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, themeManager.current.spacing.md)
    }

    @ViewBuilder
    private var exercisesEmptyState: some View {
        let theme = themeManager.current

        VStack(spacing: theme.spacing.md) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 40))
                .foregroundStyle(theme.colors.textTertiary)

            Text("No exercises added")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)

            RLButton("Add Exercise", icon: "plus", style: .secondary, size: .small) {
                showExercisePicker = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.xl)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private var exercisesList: some View {
        let theme = themeManager.current

        VStack(spacing: 0) {
            ForEach(Array(exerciseIds.enumerated()), id: \.element) { index, exerciseId in
                if let exercise = exerciseFor(id: exerciseId) {
                    exerciseRow(exercise: exercise, index: index)

                    if index < exerciseIds.count - 1 {
                        Divider()
                            .background(theme.colors.divider)
                            .padding(.leading, 56)
                    }
                }
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .padding(.horizontal, theme.spacing.md)
    }

    @ViewBuilder
    private func exerciseRow(exercise: Exercise, index: Int) -> some View {
        TemplateExerciseRow(
            exercise: exercise,
            index: index,
            canMoveUp: index > 0,
            canMoveDown: index < exerciseIds.count - 1,
            onMoveUp: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    moveExercise(from: index, to: index - 1)
                }
            },
            onMoveDown: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    moveExercise(from: index, to: index + 1)
                }
            },
            onDelete: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    _ = exerciseIds.remove(at: index)
                }
            }
        )
    }

    @ViewBuilder
    private var addExerciseButton: some View {
        let theme = themeManager.current

        Button {
            showExercisePicker = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(theme.colors.accent)
                Text("Add Exercise")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.accent)
                Spacer()
            }
            .padding(theme.spacing.md)
            .background(theme.colors.surface.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        }
        .padding(.horizontal, theme.spacing.md)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                if hasChanges {
                    showDiscardAlert = true
                } else {
                    dismiss()
                }
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                saveTemplate()
            }
            .disabled(!canSave)
            .fontWeight(.semibold)
        }
    }

    // MARK: - Helpers

    private var canSave: Bool {
        !templateName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var hasChanges: Bool {
        switch mode {
        case .create:
            return !templateName.isEmpty || !exerciseIds.isEmpty
        case .edit(let template):
            return templateName != template.name || exerciseIds != template.orderedExerciseIds
        }
    }

    private func exerciseFor(id: UUID) -> Exercise? {
        allExercises.first { $0.id == id }
    }

    private func loadTemplate() {
        if case .edit(let template) = mode {
            templateName = template.name
            exerciseIds = template.orderedExerciseIds
        }
    }

    private func moveExercise(from source: Int, to destination: Int) {
        guard source != destination,
              source >= 0, source < exerciseIds.count,
              destination >= 0, destination < exerciseIds.count else { return }

        let item = exerciseIds.remove(at: source)
        exerciseIds.insert(item, at: destination)
    }

    private func saveTemplate() {
        let trimmedName = templateName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        switch mode {
        case .create:
            let template = Template(
                name: trimmedName,
                orderedExerciseIds: exerciseIds
            )
            modelContext.insert(template)
        case .edit(let template):
            template.name = trimmedName
            template.orderedExerciseIds = exerciseIds
        }

        try? modelContext.save()
        dismiss()
    }
}

/// Row component for an exercise in the template editor
private struct TemplateExerciseRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise
    let index: Int
    let canMoveUp: Bool
    let canMoveDown: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDelete: () -> Void

    var body: some View {
        let theme = themeManager.current

        HStack(spacing: theme.spacing.md) {
            exerciseNumberBadge
            exerciseInfo
            Spacer()
            reorderButtons
            deleteButton
        }
        .padding(theme.spacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(index + 1). \(exercise.name)")
    }

    private var exerciseNumberBadge: some View {
        let theme = themeManager.current
        return Text("\(index + 1)")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(theme.colors.textSecondary)
            .frame(width: 24, height: 24)
            .background(theme.colors.elevated)
            .clipShape(Circle())
    }

    private var exerciseInfo: some View {
        let theme = themeManager.current
        return VStack(alignment: .leading, spacing: 2) {
            Text(exercise.name)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.text)
                .lineLimit(1)
            Text(exercise.muscleGroup.displayName)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private var reorderButtons: some View {
        let theme = themeManager.current
        return HStack(spacing: 4) {
            Button(action: onMoveUp) {
                Image(systemName: "chevron.up")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(canMoveUp ? theme.colors.textSecondary : theme.colors.textTertiary.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            .disabled(!canMoveUp)

            Button(action: onMoveDown) {
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(canMoveDown ? theme.colors.textSecondary : theme.colors.textTertiary.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            .disabled(!canMoveDown)
        }
    }

    private var deleteButton: some View {
        let theme = themeManager.current
        return Button(action: onDelete) {
            Image(systemName: "trash")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.error)
                .frame(width: 32, height: 32)
        }
    }
}

// MARK: - Preview

#Preview("TemplateEditorView - Create") {
    TemplateEditorView(mode: .create)
        .environment(ThemeManager())
}
