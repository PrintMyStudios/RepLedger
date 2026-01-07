import SwiftUI

/// Header for history view with title, subtitle, and search/filter buttons.
/// Supports inline search mode that replaces the header with a search bar.
struct HistoryHeaderView: View {
    @Environment(ThemeManager.self) private var themeManager

    let totalWorkouts: Int
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let hasActiveFilters: Bool
    let onFilterTap: () -> Void

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            // Normal header (fades out when searching)
            normalHeader
                .opacity(isSearching ? 0 : 1)

            // Search bar (fades in when searching)
            searchHeader
                .opacity(isSearching ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.2), value: isSearching)
    }

    // MARK: - Normal Header

    private var normalHeader: some View {
        let theme = themeManager.current

        return HStack(alignment: .top) {
            // Left: Title + subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("History")
                    .font(theme.header.pageTitleFont)
                    .foregroundStyle(theme.colors.text)

                Text("\(totalWorkouts) workout\(totalWorkouts == 1 ? "" : "s") completed")
                    .font(theme.header.subtitleFont)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer()

            // Right: Search + Filter pill
            HeaderActionPill {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        isSearchFocused = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: theme.header.iconSize, weight: theme.header.iconWeight))
                        .foregroundStyle(theme.colors.textSecondary)
                        .frame(width: theme.header.buttonVisualSize, height: theme.header.buttonVisualSize)
                }
                .frame(width: theme.header.buttonTapSize, height: theme.header.buttonTapSize)
                .contentShape(Rectangle())
                .buttonStyle(.plain)

                HeaderPillDivider()

                Button(action: onFilterTap) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: theme.header.iconSize, weight: theme.header.iconWeight))
                            .foregroundStyle(theme.colors.textSecondary)
                            .frame(width: theme.header.buttonVisualSize, height: theme.header.buttonVisualSize)

                        // Active filter indicator
                        if hasActiveFilters {
                            Circle()
                                .fill(theme.colors.accent)
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: 0)
                        }
                    }
                }
                .frame(width: theme.header.buttonTapSize, height: theme.header.buttonTapSize)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        let theme = themeManager.current

        return HStack(spacing: theme.spacing.sm) {
            // Search icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: theme.header.iconSize, weight: theme.header.iconWeight))
                .foregroundStyle(theme.colors.textTertiary)

            // Search field
            TextField("Search by exercise", text: $searchText)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.text)
                .focused($isSearchFocused)
                .submitLabel(.search)

            // Clear button (when text present)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: theme.header.iconSize))
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .buttonStyle(.plain)
            }

            // Cancel button
            Button("Cancel") {
                withAnimation(.easeInOut(duration: 0.2)) {
                    searchText = ""
                    isSearching = false
                    isSearchFocused = false
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(theme.colors.accent)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(theme.colors.elevated)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius.medium))
        .overlay {
            RoundedRectangle(cornerRadius: theme.cornerRadius.medium)
                .stroke(theme.colors.border, lineWidth: 1)
        }
    }
}

// MARK: - Preview

#Preview("HistoryHeaderView") {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        @State private var isSearching = false
        @State private var hasFilters = false
        private let theme = ObsidianTheme()

        var body: some View {
            ZStack {
                theme.colors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    HistoryHeaderView(
                        totalWorkouts: 42,
                        searchText: $searchText,
                        isSearching: $isSearching,
                        hasActiveFilters: hasFilters,
                        onFilterTap: { hasFilters.toggle() }
                    )
                    .padding(.horizontal)

                    Toggle("Has active filters", isOn: $hasFilters)
                        .foregroundStyle(theme.colors.text)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .environment(ThemeManager())
        }
    }

    return PreviewWrapper()
}
