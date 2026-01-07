import SwiftUI

/// Coach workspace view for managing clients (iPhone only for v1).
struct CoachView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.userSettings) private var settings

    // Client data - empty in production, optional preview in DEBUG
    #if DEBUG
    private var clients: [ClientSummary] {
        settings.showCoachPreviewData ? ClientSummary.samples : []
    }
    #else
    private let clients: [ClientSummary] = []
    #endif

    // Search and sort state
    @State private var searchText = ""
    @State private var sortBy: SortOption = .lastActive
    @State private var showComingSoonSheet = false

    enum SortOption: String, CaseIterable {
        case lastActive = "Last Active"
        case name = "Name"
        case workouts = "Workouts"
    }

    var body: some View {
        let theme = themeManager.current

        NavigationStack {
            Group {
                if filteredClients.isEmpty && searchText.isEmpty {
                    CoachEmptyStateView(showComingSoonSheet: $showComingSoonSheet)
                } else if filteredClients.isEmpty {
                    VStack {
                        Spacer()
                        RLEmptyState.noSearchResults(query: searchText)
                        Spacer()
                    }
                } else {
                    clientList(theme: theme)
                }
            }
            .background(theme.colors.background)
            .navigationTitle("Clients")
            .searchable(text: $searchText, prompt: "Search clients")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: theme.spacing.sm) {
                        sortMenu
                        inviteButton
                    }
                }
            }
            .navigationDestination(for: ClientSummary.self) { client in
                ClientDetailView(client: client)
            }
        }
        .sheet(isPresented: $showComingSoonSheet) {
            ComingSoonSheet()
        }
    }

    // MARK: - Client List

    private func clientList(theme: any Theme) -> some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing.sm) {
                ForEach(filteredClients, id: \.id) { client in
                    NavigationLink(value: client) {
                        ClientRowView(client: client)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm)
        }
    }

    // MARK: - Toolbar Items

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortBy = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortBy == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }

    private var inviteButton: some View {
        Button {
            showComingSoonSheet = true
        } label: {
            Label("Invite", systemImage: "person.badge.plus")
        }
    }

    // MARK: - Filtering and Sorting

    private var filteredClients: [ClientSummary] {
        var result = clients

        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortBy {
        case .lastActive:
            result.sort { (a, b) in
                switch (a.lastActiveAt, b.lastActiveAt) {
                case (.some(let dateA), .some(let dateB)):
                    return dateA > dateB
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return a.name < b.name
                }
            }
        case .name:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .workouts:
            result.sort { $0.workoutCount > $1.workoutCount }
        }

        return result
    }
}

// MARK: - Preview

#if DEBUG
#Preview("CoachView - Empty") {
    CoachView()
        .environment(ThemeManager())
}

#Preview("CoachView - With Clients") {
    struct PreviewWrapper: View {
        var body: some View {
            CoachView()
                .environment(ThemeManager())
                .onAppear {
                    UserSettings.shared.showCoachPreviewData = true
                }
        }
    }
    return PreviewWrapper()
}
#endif
