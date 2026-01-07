import SwiftUI

/// Filter chip options for templates
enum TemplateFilter: String, CaseIterable, Identifiable {
    case recent
    case all

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .recent: return "Recent"
        case .all: return "All"
        }
    }
}

/// Horizontal scrolling filter chips for templates.
struct TemplateFilterChipsView: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var selectedFilter: TemplateFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TemplateFilter.allCases) { filter in
                    TemplateFilterChip(
                        filter: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
        }
    }
}

// MARK: - Template Filter Chip

private struct TemplateFilterChip: View {
    @Environment(ThemeManager.self) private var themeManager

    let filter: TemplateFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        let theme = themeManager.current

        Button(action: onTap) {
            Text(filter.displayName)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? theme.colors.textOnAccent : theme.colors.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? theme.colors.accent : theme.colors.elevated)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.displayName) filter")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview("TemplateFilterChipsView") {
    struct PreviewWrapper: View {
        @State private var selected: TemplateFilter = .recent
        private let theme = ObsidianTheme()

        var body: some View {
            ZStack {
                theme.colors.background.ignoresSafeArea()

                VStack {
                    TemplateFilterChipsView(selectedFilter: $selected)
                        .padding(.horizontal, 20)

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
