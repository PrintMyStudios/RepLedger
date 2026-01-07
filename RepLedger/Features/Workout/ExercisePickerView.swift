import SwiftUI
import SwiftData

/// Modal sheet for searching and selecting exercises from the library.
/// Used for both template editing and adding exercises to active workouts.
struct ExercisePickerView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var selectedMuscleGroup: MuscleGroup?

    /// Callback when an exercise is selected
    let onSelect: (Exercise) -> Void

    /// Optional: exercises to exclude from the list (e.g., already added)
    var excludedExerciseIds: Set<UUID> = []

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            VStack(spacing: 0) {
                // Muscle group filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        FilterPill(
                            title: "All",
                            isSelected: selectedMuscleGroup == nil
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMuscleGroup = nil
                            }
                        }

                        ForEach(MuscleGroup.allCases) { group in
                            FilterPill(
                                title: group.displayName,
                                isSelected: selectedMuscleGroup == group
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedMuscleGroup = group
                                }
                            }
                        }
                    }
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.sm)
                }
                .background(theme.colors.surface)

                Divider()
                    .background(theme.colors.divider)

                // Exercise list
                Group {
                    if filteredExercises.isEmpty {
                        if searchText.isEmpty && selectedMuscleGroup == nil {
                            RLEmptyState(
                                icon: "dumbbell.fill",
                                title: "No Exercises",
                                subtitle: "Exercise library is empty."
                            )
                        } else {
                            RLEmptyState.noSearchResults(query: searchText.isEmpty ? selectedMuscleGroup?.displayName ?? "" : searchText)
                        }
                    } else {
                        List {
                            ForEach(groupedExercises.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { group in
                                if let groupExercises = groupedExercises[group], !groupExercises.isEmpty {
                                    Section {
                                        ForEach(groupExercises) { exercise in
                                            ExercisePickerRow(exercise: exercise) {
                                                onSelect(exercise)
                                                dismiss()
                                            }
                                        }
                                    } header: {
                                        Text(group.displayName)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .background(theme.colors.background)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredExercises: [Exercise] {
        var result = exercises.filter { !excludedExerciseIds.contains($0.id) }

        if let group = selectedMuscleGroup {
            result = result.filter { $0.muscleGroup == group }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    private var groupedExercises: [MuscleGroup: [Exercise]] {
        Dictionary(grouping: filteredExercises, by: \.muscleGroup)
    }
}

/// Row component for exercise picker
private struct ExercisePickerRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            HStack(spacing: theme.spacing.md) {
                Image(systemName: exercise.muscleGroup.icon)
                    .font(.title3)
                    .foregroundStyle(theme.colors.accent)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.text)

                    Text(exercise.equipment.displayName)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(theme.colors.accent)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(exercise.name), \(exercise.muscleGroup.displayName), \(exercise.equipment.displayName)")
        .accessibilityHint("Double tap to add")
    }
}

/// Filter pill button for muscle group selection
private struct FilterPill: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? theme.colors.textOnAccent : theme.colors.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? theme.colors.accent : theme.colors.elevated)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview("ExercisePickerView") {
    ExercisePickerView { exercise in
        print("Selected: \(exercise.name)")
    }
    .environment(ThemeManager())
}
