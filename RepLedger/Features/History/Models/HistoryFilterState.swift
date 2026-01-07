import Foundation

/// Time period filter options for history view
enum HistoryTimePeriod: String, CaseIterable, Identifiable {
    case all
    case week
    case month
    case prsOnly
    case templates

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .week: return "Week"
        case .month: return "Month"
        case .prsOnly: return "PRs"
        case .templates: return "Templates"
        }
    }

    var icon: String? {
        switch self {
        case .prsOnly: return "trophy.fill"
        default: return nil
        }
    }
}

/// Section grouping type for history timeline
enum HistorySectionType: Equatable {
    case thisWeek
    case lastWeek
    case month(year: Int, month: Int)

    var displayTitle: String {
        switch self {
        case .thisWeek:
            return "THIS WEEK"
        case .lastWeek:
            return "LAST WEEK"
        case .month(let year, let month):
            let components = DateComponents(year: year, month: month)
            guard let date = Calendar.current.date(from: components) else {
                return "\(month)/\(year)"
            }
            return Self.monthFormatter.string(from: date).uppercased()
        }
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    /// Order for sorting (lower = more recent)
    var sortOrder: Int {
        switch self {
        case .thisWeek: return 0
        case .lastWeek: return 1
        case .month: return 2
        }
    }
}

extension HistorySectionType: Comparable {
    static func < (lhs: HistorySectionType, rhs: HistorySectionType) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        // Both are months - compare by date (newer first)
        if case .month(let lhsYear, let lhsMonth) = lhs,
           case .month(let rhsYear, let rhsMonth) = rhs {
            if lhsYear != rhsYear { return lhsYear > rhsYear }
            return lhsMonth > rhsMonth
        }
        return false
    }
}

extension HistorySectionType: Hashable {}

/// State for history filtering
@Observable
final class HistoryFilterState {
    /// Currently selected time period filter
    var selectedPeriod: HistoryTimePeriod = .all

    /// Search query for inline search
    var searchText: String = ""

    /// Whether search mode is active
    var isSearching: Bool = false

    /// Selected muscle groups for filtering (empty = all)
    var selectedMuscleGroups: Set<MuscleGroup> = []

    /// Selected template IDs for filtering (empty = all)
    var selectedTemplateIds: Set<UUID> = []

    /// Whether to show only workouts with PRs
    var showPRsOnly: Bool = false

    /// Date range for advanced filtering
    var startDate: Date?
    var endDate: Date?

    /// Collapsed section keys
    var collapsedSections: Set<HistorySectionType> = []

    // MARK: - Computed

    var hasActiveFilters: Bool {
        selectedPeriod != .all ||
        !selectedMuscleGroups.isEmpty ||
        !selectedTemplateIds.isEmpty ||
        showPRsOnly ||
        startDate != nil ||
        endDate != nil
    }

    var activeFilterCount: Int {
        var count = 0
        if selectedPeriod != .all { count += 1 }
        if !selectedMuscleGroups.isEmpty { count += selectedMuscleGroups.count }
        if !selectedTemplateIds.isEmpty { count += selectedTemplateIds.count }
        if showPRsOnly { count += 1 }
        if startDate != nil || endDate != nil { count += 1 }
        return count
    }

    // MARK: - Actions

    func reset() {
        selectedPeriod = .all
        searchText = ""
        isSearching = false
        selectedMuscleGroups = []
        selectedTemplateIds = []
        showPRsOnly = false
        startDate = nil
        endDate = nil
    }

    func toggleSection(_ section: HistorySectionType) {
        if collapsedSections.contains(section) {
            collapsedSections.remove(section)
        } else {
            collapsedSections.insert(section)
        }
    }

    func isSectionCollapsed(_ section: HistorySectionType) -> Bool {
        collapsedSections.contains(section)
    }
}

/// Group of workouts for a section
struct HistorySectionGroup: Identifiable {
    let section: HistorySectionType
    let workouts: [Workout]
    let sessionCount: Int
    let totalVolume: Double

    var id: HistorySectionType { section }

    var statsText: String {
        let volumeK = totalVolume / 1000
        let volumeStr = volumeK >= 1 ? String(format: "%.1fk", volumeK) : String(format: "%.0f", totalVolume)
        return "\(sessionCount) Session\(sessionCount == 1 ? "" : "s") • \(volumeStr) Vol"
    }
}
