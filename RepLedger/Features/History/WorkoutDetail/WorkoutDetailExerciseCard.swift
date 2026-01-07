import SwiftUI

/// Expandable exercise card for workout detail view
/// Shows exercise info, top set/best vol callouts, and sets table with PR highlighting
struct WorkoutDetailExerciseCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    let workoutExercise: WorkoutExercise
    let exercise: Exercise
    let prInfo: [WorkoutSetPR]  // PRs for this exercise
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        let theme = themeManager.current

        VStack(spacing: 0) {
            if isExpanded {
                expandedContent
            } else {
                collapsedContent
            }
        }
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.large)
                .stroke(theme.colors.border, lineWidth: 1)
        }
        .rlShadow(theme.shadows.card)
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        let theme = themeManager.current

        return VStack(spacing: 0) {
            // Header (tappable to collapse)
            expandedHeader
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onToggle()
                    }
                }

            // Top Set / Best Vol callout bar
            if let topSet = workoutExercise.bestSet {
                topSetCalloutBar(topSet)
            }

            // Sets table
            setsTable
        }
    }

    private var expandedHeader: some View {
        let theme = themeManager.current

        return HStack(spacing: theme.spacing.md) {
            // Abbreviation box
            abbreviationBox

            // Exercise info
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                Text("\(exercise.muscleGroup.displayName) • \(exercise.equipment.displayName)")
                    .font(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }

            Spacer()

            // Chevron (down when expanded)
            Image(systemName: "chevron.down")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .background(theme.colors.surface)
    }

    private func topSetCalloutBar(_ topSet: SetEntry) -> some View {
        let theme = themeManager.current

        return HStack(spacing: theme.spacing.md) {
            // Top Set
            VStack(alignment: .leading, spacing: 2) {
                Text("TOP SET")
                    .font(.caption2.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(theme.colors.textTertiary)

                if let weight = topSet.weight, let reps = topSet.reps {
                    Text("\(weight.formatWeight(unit: settings.liftingUnit, decimals: 1)) × \(reps)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.colors.text)
                }
            }

            // Divider
            Rectangle()
                .fill(theme.colors.divider)
                .frame(width: 1, height: 32)

            // Best Volume (if different from top set)
            if let bestVolumeSet = bestVolumeSet, bestVolumeSet.id != topSet.id {
                VStack(alignment: .leading, spacing: 2) {
                    Text("BEST VOL")
                        .font(.caption2.weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(theme.colors.textTertiary)

                    if let weight = bestVolumeSet.weight, let reps = bestVolumeSet.reps {
                        Text("\(weight.formatWeight(unit: settings.liftingUnit, decimals: 0)) × \(reps)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.colors.text)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.elevated.opacity(0.5))
    }

    private var setsTable: some View {
        let theme = themeManager.current

        return VStack(spacing: 0) {
            // Table header
            HStack {
                Text("SET")
                    .frame(width: 36, alignment: .leading)

                Text(settings.liftingUnit.abbreviation.uppercased())
                    .frame(width: 70, alignment: .trailing)

                Text("REPS")
                    .frame(width: 50, alignment: .trailing)

                Spacer()
            }
            .font(.caption2.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
            .background(theme.colors.elevated.opacity(0.3))

            // Set rows
            ForEach(Array(completedSets.enumerated()), id: \.element.id) { index, set in
                setRow(set, index: index + 1)
            }
        }
    }

    private func setRow(_ set: SetEntry, index: Int) -> some View {
        let theme = themeManager.current
        let prForSet = prInfo.first { $0.setId == set.id }
        let isPR = prForSet != nil
        let isVolumePR = prForSet?.prType == .maxVolume

        // Determine row styling
        let rowColor: Color = {
            if isVolumePR {
                return theme.colors.accentOrange
            } else if isPR {
                return theme.colors.accent
            }
            return theme.colors.text
        }()

        let rowBackground: Color = {
            if isVolumePR {
                return theme.colors.accentOrange.opacity(0.08)
            } else if isPR {
                return theme.colors.accent.opacity(0.08)
            }
            return .clear
        }()

        return HStack {
            // Set number
            Text("\(index)")
                .frame(width: 36, alignment: .leading)
                .foregroundStyle(isPR ? rowColor : theme.colors.textSecondary)

            // Weight (right-aligned)
            Text(set.formattedWeight(unit: settings.liftingUnit))
                .frame(width: 70, alignment: .trailing)
                .foregroundStyle(isPR ? rowColor : theme.colors.text)
                .fontWeight(isPR ? .bold : .regular)

            // Reps (right-aligned)
            Text(set.formattedReps)
                .frame(width: 50, alignment: .trailing)
                .foregroundStyle(isPR ? rowColor : theme.colors.text)
                .fontWeight(isPR ? .bold : .regular)

            Spacer()

            // Tag column
            if let prForSet = prForSet {
                prBadge(for: prForSet.prType)
            } else if set.setType == .warmup {
                warmupTag
            }
        }
        .font(.subheadline)
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, 10)
        .background(rowBackground)
        .overlay(alignment: .bottom) {
            if index < completedSets.count {
                Rectangle()
                    .fill(theme.colors.divider.opacity(0.5))
                    .frame(height: 0.5)
            }
        }
    }

    private func prBadge(for prType: PRType) -> some View {
        let theme = themeManager.current

        // Use consistent badge labels from PRType
        let color: Color = prType == .maxVolume ? theme.colors.accentOrange : theme.colors.accent

        return Text(prType.badgeText)
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var warmupTag: some View {
        let theme = themeManager.current

        return Text("Warmup")
            .font(.caption2.weight(.medium))
            .foregroundStyle(theme.colors.textTertiary)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(theme.colors.elevated)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Collapsed Content

    private var collapsedContent: some View {
        let theme = themeManager.current

        return HStack(spacing: theme.spacing.md) {
            // Abbreviation box (smaller)
            abbreviationBoxSmall

            // Exercise info
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(theme.colors.text)
                    .lineLimit(1)

                HStack(spacing: theme.spacing.xs) {
                    Text(exercise.muscleGroup.displayName)
                        .font(.caption)
                        .foregroundStyle(theme.colors.textTertiary)

                    if let topSet = workoutExercise.bestSet, let weight = topSet.weight, let reps = topSet.reps {
                        Circle()
                            .fill(theme.colors.textTertiary)
                            .frame(width: 3, height: 3)

                        Text("Top: \(weight.formatWeight(unit: settings.liftingUnit, decimals: 1)) × \(reps)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(theme.colors.accent)
                    }

                    Circle()
                        .fill(theme.colors.textTertiary)
                        .frame(width: 3, height: 3)

                    Text("\(completedSets.count) Sets")
                        .font(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Spacer()

            // PR indicator (if any)
            if !prInfo.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                    Text("\(prInfo.count)")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(prInfo.count > 1 ? theme.colors.accentGold : theme.colors.accent)
            }

            // Chevron (right when collapsed)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onToggle()
            }
        }
    }

    // MARK: - Shared Components

    private var abbreviationBox: some View {
        let theme = themeManager.current

        return Text(abbreviation)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(theme.colors.accent)
            .frame(width: 40, height: 40)
            .background(theme.colors.elevated)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
    }

    private var abbreviationBoxSmall: some View {
        let theme = themeManager.current

        return Text(abbreviation)
            .font(.caption.weight(.bold))
            .foregroundStyle(theme.colors.textTertiary)
            .frame(width: 36, height: 36)
            .background(theme.colors.elevated)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.small))
    }

    // MARK: - Helpers

    private var abbreviation: String {
        let words = exercise.name
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        let initials = words.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined().uppercased()
    }

    private var completedSets: [SetEntry] {
        workoutExercise.orderedSets.filter { $0.isCompleted }
    }

    private var bestVolumeSet: SetEntry? {
        completedSets
            .filter { $0.volume != nil }
            .max { ($0.volume ?? 0) < ($1.volume ?? 0) }
    }
}

// MARK: - Preview

#Preview("WorkoutDetailExerciseCard") {
    struct PreviewWrapper: View {
        @State private var isExpanded = true

        var body: some View {
            ZStack {
                ObsidianTheme().colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // Note: This preview needs actual model data to work properly
                        Text("Preview requires model data")
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
            }
            .environment(ThemeManager())
        }
    }

    return PreviewWrapper()
}
