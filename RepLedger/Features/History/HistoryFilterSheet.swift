import SwiftUI
import SwiftData

/// Advanced filter sheet for history view
struct HistoryFilterSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Bindable var filterState: HistoryFilterState

    @Query(sort: \Template.name) private var templates: [Template]

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            ScrollView {
                VStack(spacing: theme.spacing.lg) {
                    // Date Range Section
                    dateRangeSection

                    Divider()
                        .background(theme.colors.divider)

                    // Muscle Groups Section
                    muscleGroupsSection

                    Divider()
                        .background(theme.colors.divider)

                    // Templates Section
                    templatesSection

                    Divider()
                        .background(theme.colors.divider)

                    // PRs Only Toggle
                    prsToggle
                }
                .padding(theme.spacing.md)
            }
            .background(theme.colors.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filterState.reset()
                    }
                    .foregroundStyle(theme.colors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.accent)
                }
            }
            .toolbarBackground(theme.colors.surface, for: .navigationBar)
        }
    }

    // MARK: - Date Range Section

    private var dateRangeSection: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("DATE RANGE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(theme.colors.textSecondary)

            HStack(spacing: theme.spacing.md) {
                // Start date
                VStack(alignment: .leading, spacing: 4) {
                    Text("From")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.colors.textTertiary)

                    DatePickerButton(
                        date: $filterState.startDate,
                        placeholder: "Any"
                    )
                }

                // End date
                VStack(alignment: .leading, spacing: 4) {
                    Text("To")
                        .font(.system(size: 12))
                        .foregroundStyle(theme.colors.textTertiary)

                    DatePickerButton(
                        date: $filterState.endDate,
                        placeholder: "Any"
                    )
                }
            }
        }
    }

    // MARK: - Muscle Groups Section

    private var muscleGroupsSection: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text("MUSCLE GROUPS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(theme.colors.textSecondary)

                Spacer()

                if !filterState.selectedMuscleGroups.isEmpty {
                    Button("Clear") {
                        filterState.selectedMuscleGroups.removeAll()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.accent)
                }
            }

            FlowLayout(spacing: theme.spacing.sm) {
                ForEach(MuscleGroup.allCases) { muscle in
                    MuscleChip(
                        muscle: muscle,
                        isSelected: filterState.selectedMuscleGroups.contains(muscle),
                        onTap: {
                            if filterState.selectedMuscleGroups.contains(muscle) {
                                filterState.selectedMuscleGroups.remove(muscle)
                            } else {
                                filterState.selectedMuscleGroups.insert(muscle)
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Templates Section

    private var templatesSection: some View {
        let theme = themeManager.current

        return VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack {
                Text("TEMPLATES")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(theme.colors.textSecondary)

                Spacer()

                if !filterState.selectedTemplateIds.isEmpty {
                    Button("Clear") {
                        filterState.selectedTemplateIds.removeAll()
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(theme.colors.accent)
                }
            }

            if templates.isEmpty {
                Text("No templates created yet")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .padding(.vertical, theme.spacing.sm)
            } else {
                FlowLayout(spacing: theme.spacing.sm) {
                    ForEach(templates) { template in
                        TemplateChip(
                            name: template.name,
                            isSelected: filterState.selectedTemplateIds.contains(template.id),
                            onTap: {
                                if filterState.selectedTemplateIds.contains(template.id) {
                                    filterState.selectedTemplateIds.remove(template.id)
                                } else {
                                    filterState.selectedTemplateIds.insert(template.id)
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - PRs Toggle

    private var prsToggle: some View {
        let theme = themeManager.current

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Show PRs Only")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.text)

                Text("Only show workouts where you set a personal record")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }

            Spacer()

            Toggle("", isOn: $filterState.showPRsOnly)
                .labelsHidden()
                .tint(theme.colors.accent)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
    }
}

// MARK: - Date Picker Button

private struct DatePickerButton: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var date: Date?
    let placeholder: String

    @State private var showPicker = false

    var body: some View {
        let theme = themeManager.current

        Button {
            showPicker = true
        } label: {
            HStack {
                Text(date?.formatted(date: .abbreviated, time: .omitted) ?? placeholder)
                    .font(theme.typography.body)
                    .foregroundStyle(date == nil ? theme.colors.textTertiary : theme.colors.text)

                Spacer()

                if date != nil {
                    Button {
                        date = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
            .overlay {
                RoundedRectangle(cornerRadius: theme.cornerRadius.small)
                    .stroke(theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            DatePickerSheet(date: $date)
        }
    }
}

// MARK: - Date Picker Sheet

private struct DatePickerSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Binding var date: Date?
    @State private var selectedDate = Date()

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(theme.colors.accent)
                .padding()
            }
            .background(theme.colors.background)
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(theme.colors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Select") {
                        date = selectedDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.accent)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            selectedDate = date ?? Date()
        }
    }
}

// MARK: - Muscle Chip

private struct MuscleChip: View {
    @Environment(ThemeManager.self) private var themeManager

    let muscle: MuscleGroup
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            Text(muscle.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? theme.colors.background : theme.colors.text)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .background(isSelected ? theme.colors.accent : theme.colors.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? theme.colors.accent : theme.colors.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Template Chip

private struct TemplateChip: View {
    @Environment(ThemeManager.self) private var themeManager

    let name: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.system(size: 10))

                Text(name)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundStyle(isSelected ? theme.colors.background : theme.colors.text)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(isSelected ? theme.colors.accent : theme.colors.surface)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? theme.colors.accent : theme.colors.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func flowLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

// MARK: - Preview

#Preview("HistoryFilterSheet") {
    HistoryFilterSheet(filterState: HistoryFilterState())
        .environment(ThemeManager())
        .modelContainer(for: [Template.self])
}
