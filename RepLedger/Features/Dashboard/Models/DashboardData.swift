import Foundation

// MARK: - Shared Time-Ago Helper

/// Shared formatter for relative date strings (Today, Yesterday, Nd ago)
enum TimeAgoFormatter {
    static func format(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
        guard days > 0 else { return "Today" } // Safeguard against negative/future dates
        return "\(days)d ago"
    }
}

// MARK: - Dashboard Data Models

/// Container for all dashboard data loaded from MetricsActor
struct DashboardData {
    let stats: DashboardStats
    let weeklyVolumeByDay: [Double]      // exactly 7 entries aligned Mon–Sun
    let lastWorkout: LastWorkoutData?
    let latestPR: LatestPRData?
    let recovery: [RecoveryItem]         // 0–2 items max
    let hasAnyWorkouts: Bool             // Used for empty state detection
}

/// Weekly stats for DashboardStatsCard
struct DashboardStats {
    let weeklyVolume: Double
    let volumeTrend: TrendDisplay        // handles lastWeek=0 cleanly
    let sessionsCompleted: Int
    let sessionsGoal: Int
}

/// Trend display with proper zero handling
enum TrendDisplay {
    case percentage(Double)   // normal trend
    case new                  // lastWeek=0, thisWeek>0
    case none                 // both weeks = 0

    var text: String {
        switch self {
        case .percentage(let pct):
            let sign = pct >= 0 ? "+" : ""
            return "\(sign)\(Int(pct))%"
        case .new:
            return "New"
        case .none:
            return "—"
        }
    }

    var isPositive: Bool {
        switch self {
        case .percentage(let pct): return pct >= 0
        case .new: return true
        case .none: return false
        }
    }
}

/// Data for LastWorkoutCard
struct LastWorkoutData: Identifiable {
    let id: UUID                         // workout.id
    let muscleGroup: MuscleGroup?
    let date: Date
    let durationSeconds: Int?
    let volume: Double
    let prCount: Int

    var timeAgoText: String {
        TimeAgoFormatter.format(date)
    }

    var durationText: String {
        guard let seconds = durationSeconds, seconds > 0 else { return "—" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

/// Data for LatestPRCard
struct LatestPRData: Identifiable {
    let id: UUID                         // setId
    let exerciseName: String
    let prType: PRType
    let weight: Double
    let reps: Int?
    let achievedAt: Date

    var timeAgoText: String {
        TimeAgoFormatter.format(achievedAt)
    }
}

/// Data for RecoveryCard
struct RecoveryItem: Identifiable {
    var id: MuscleGroup { muscle }       // MuscleGroup is already Identifiable
    let muscle: MuscleGroup
    let recovered: Double                // 0.0–1.0
    let hoursSinceTraining: Int
}
