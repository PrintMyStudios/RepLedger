import SwiftUI

/// Horizontal scrolling filter chips for history view.
/// Uses lighter visual weight with subtle selection states.
struct HistoryFilterChipsView: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var selectedPeriod: HistoryTimePeriod

    var body: some View {
        let theme = themeManager.current

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(HistoryTimePeriod.allCases) { period in
                    FilterChip(
                        period: period,
                        isSelected: selectedPeriod == period,
                        onTap: { selectedPeriod = period }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    @Environment(ThemeManager.self) private var themeManager

    let period: HistoryTimePeriod
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            HStack(spacing: 4) {
                // Icon for PRs
                if let icon = period.icon {
                    Image(systemName: icon)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(isSelected ? theme.colors.background : theme.colors.accentGold)
                }

                Text(period.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? theme.colors.background : theme.colors.text)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(chipBackground)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(period.displayName) filter")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var chipBackground: Color {
        let theme = themeManager.current
        if isSelected {
            return theme.colors.accent
        }
        // Gold tint for PRs chip when not selected
        if period == .prsOnly {
            return theme.colors.accentGold.opacity(0.12)
        }
        return theme.colors.elevated
    }
}

// MARK: - Preview

#Preview("HistoryFilterChipsView") {
    struct PreviewWrapper: View {
        @State private var selected: HistoryTimePeriod = .all
        private let theme = ObsidianTheme()

        var body: some View {
            ZStack {
                theme.colors.background.ignoresSafeArea()

                VStack {
                    HistoryFilterChipsView(selectedPeriod: $selected)

                    Text("Selected: \(selected.displayName)")
                        .foregroundStyle(theme.colors.text)
                        .padding(.top, 20)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .environment(ThemeManager())
        }
    }

    return PreviewWrapper()
}
