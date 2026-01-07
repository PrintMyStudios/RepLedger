import Foundation

/// Protocol for any client data that can be displayed in Coach views.
/// Future real Client model (from backend) will conform to this protocol,
/// allowing views to work seamlessly with both stub and real data.
protocol CoachClientPresentable: Identifiable, Hashable {
    var id: UUID { get }
    var name: String { get }
    var email: String { get }
    var joinedAt: Date { get }
    var lastActiveAt: Date? { get }
    var workoutCount: Int { get }
    var templateCount: Int { get }
}

/// In-memory client model for Coach UI skeleton.
/// Not persisted - used only for UI display in v1.
/// Will be replaced by real Client model with backend in v2.
struct ClientSummary: CoachClientPresentable {
    let id: UUID
    let name: String
    let email: String
    let joinedAt: Date
    let lastActiveAt: Date?
    let workoutCount: Int
    let templateCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        joinedAt: Date = Date(),
        lastActiveAt: Date? = nil,
        workoutCount: Int = 0,
        templateCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.joinedAt = joinedAt
        self.lastActiveAt = lastActiveAt
        self.workoutCount = workoutCount
        self.templateCount = templateCount
    }
}

// MARK: - Computed Properties

extension ClientSummary {
    /// Returns the client's initials (up to 2 characters) for avatar display.
    var initials: String {
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map(String.init)
        return initials.joined().uppercased()
    }

    /// Returns true if the client was active within the last 7 days.
    var isRecentlyActive: Bool {
        guard let lastActive = lastActiveAt else { return false }
        return Date().timeIntervalSince(lastActive) < 86400 * 7
    }

    /// Returns a formatted "last active" string for display.
    var lastActiveFormatted: String {
        guard let lastActive = lastActiveAt else { return "Never" }
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(lastActive) {
            return "Today"
        } else if calendar.isDateInYesterday(lastActive) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: lastActive, to: now).day ?? 0
            if days < 7 {
                return "\(days)d ago"
            } else if days < 30 {
                let weeks = days / 7
                return "\(weeks)w ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: lastActive)
            }
        }
    }

    /// Returns a formatted join date string.
    var joinedAtFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: joinedAt)
    }
}
