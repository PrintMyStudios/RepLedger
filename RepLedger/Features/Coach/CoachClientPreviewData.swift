#if DEBUG
import Foundation

/// Sample client data for development and testing.
/// Only available in DEBUG builds.
extension ClientSummary {
    /// Sample clients for previewing Coach UI.
    static let samples: [ClientSummary] = [
        ClientSummary(
            name: "Alex Johnson",
            email: "alex.johnson@example.com",
            joinedAt: Date().addingTimeInterval(-86400 * 45), // 45 days ago
            lastActiveAt: Date().addingTimeInterval(-86400 * 1), // Yesterday
            workoutCount: 32,
            templateCount: 4
        ),
        ClientSummary(
            name: "Sam Williams",
            email: "sam.williams@example.com",
            joinedAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            lastActiveAt: Date().addingTimeInterval(-3600 * 4), // 4 hours ago
            workoutCount: 18,
            templateCount: 2
        ),
        ClientSummary(
            name: "Jordan Lee",
            email: "jordan.lee@example.com",
            joinedAt: Date().addingTimeInterval(-86400 * 14), // 14 days ago
            lastActiveAt: Date().addingTimeInterval(-86400 * 3), // 3 days ago
            workoutCount: 8,
            templateCount: 1
        ),
        ClientSummary(
            name: "Morgan Chen",
            email: "morgan.chen@example.com",
            joinedAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            lastActiveAt: nil, // Never logged in
            workoutCount: 0,
            templateCount: 0
        ),
        ClientSummary(
            name: "Taylor Swift",
            email: "taylor.swift@example.com",
            joinedAt: Date().addingTimeInterval(-86400 * 60), // 60 days ago
            lastActiveAt: Date().addingTimeInterval(-86400 * 14), // 2 weeks ago
            workoutCount: 45,
            templateCount: 5
        )
    ]

    /// Single sample client for simple previews.
    static let sample = samples[0]
}
#endif
