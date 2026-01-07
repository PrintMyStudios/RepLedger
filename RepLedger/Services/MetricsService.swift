import Foundation
import SwiftData

/// Personal record types tracked per exercise
enum PRType: String, CaseIterable, Sendable {
    case maxWeight  // Heaviest weight lifted
    case maxE1RM    // Highest estimated 1RM
    case maxVolume  // Highest volume in a single set

    /// Title case for cards, section headers
    var titleText: String {
        switch self {
        case .maxWeight: return "Max Load"
        case .maxE1RM: return "Max 1RM"
        case .maxVolume: return "Max Set Vol"
        }
    }

    /// ALL CAPS for pills/badges
    var badgeText: String {
        switch self {
        case .maxWeight: return "MAX LOAD"
        case .maxE1RM: return "MAX 1RM"
        case .maxVolume: return "MAX SET VOL"
        }
    }

    var icon: String {
        switch self {
        case .maxWeight: return "scalemass.fill"
        case .maxE1RM: return "trophy.fill"
        case .maxVolume: return "chart.bar.fill"
        }
    }
}

/// Represents a personal record for an exercise
struct PersonalRecord: Sendable {
    let type: PRType
    let value: Double
    let setId: UUID
    let workoutId: UUID
    let achievedAt: Date
}

/// Represents PRs achieved in a specific workout (for badges)
struct WorkoutPRResult: Sendable {
    let exerciseId: UUID
    let prType: PRType
    let setId: UUID
    let previousValue: Double?
}

/// Summary of exercise performance in a workout (for history display)
struct ExerciseHistorySummary: Sendable {
    let workoutId: UUID
    let workoutTitle: String
    let date: Date
    let setCount: Int
    let totalVolume: Double
    let bestWeight: Double?
    let bestE1RM: Double?
}

/// Rich PR result for workout detail view with exercise name and PR value
struct WorkoutSetPR: Sendable, Identifiable {
    /// Unique ID combining setId and prType to ensure each PR is distinct in ForEach
    var id: String { "\(setId.uuidString)-\(prType.rawValue)" }
    let exerciseId: UUID
    let exerciseName: String
    let setId: UUID
    let prType: PRType
    let value: Double           // The PR value achieved
    let previousBest: Double?   // Prior best (for display: "Previous: X")
    let weight: Double?         // Weight used (for display)
    let reps: Int?              // Reps performed (for display)

    init(exerciseId: UUID, exerciseName: String, setId: UUID, prType: PRType, value: Double, previousBest: Double?, weight: Double?, reps: Int?) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.setId = setId
        self.prType = prType
        self.value = value
        self.previousBest = previousBest
        self.weight = weight
        self.reps = reps
    }
}

/// Thread-safe actor for metrics calculations using SwiftData.
/// Uses @ModelActor to safely access SwiftData from background threads.
@ModelActor
actor MetricsActor {
    // MARK: - Personal Records

    /// Get all personal records for an exercise
    func getPersonalRecords(for exerciseId: UUID) -> [PRType: PersonalRecord] {
        let completedWorkouts = fetchCompletedWorkouts()
        return calculatePRs(for: exerciseId, fromWorkouts: completedWorkouts)
    }

    /// Get PRs achieved in a specific workout
    func getPRsInWorkout(_ workoutId: UUID) -> [WorkoutPRResult] {
        guard let workout = fetchWorkout(by: workoutId) else { return [] }

        // Fetch all completed workouts BEFORE this workout
        let priorWorkouts = fetchCompletedWorkouts(before: workout.startedAt)

        // Precompute prior best per exercise in ONE PASS (O(N) instead of O(N*M))
        var priorBest: [UUID: [PRType: Double]] = [:]
        for prior in priorWorkouts {
            for we in prior.orderedExercises {
                let exerciseId = we.exerciseId
                if priorBest[exerciseId] == nil {
                    priorBest[exerciseId] = [:]
                }

                for set in we.orderedSets where set.isCompleted {
                    if let weight = set.weight {
                        let current = priorBest[exerciseId]![.maxWeight] ?? 0
                        priorBest[exerciseId]![.maxWeight] = max(current, weight)
                    }
                    if let e1rm = set.estimated1RM {
                        let current = priorBest[exerciseId]![.maxE1RM] ?? 0
                        priorBest[exerciseId]![.maxE1RM] = max(current, e1rm)
                    }
                    if let volume = set.volume {
                        let current = priorBest[exerciseId]![.maxVolume] ?? 0
                        priorBest[exerciseId]![.maxVolume] = max(current, volume)
                    }
                }
            }
        }

        // Compare each exercise in THIS workout against precomputed map
        var results: [WorkoutPRResult] = []
        for workoutExercise in workout.orderedExercises {
            let exerciseId = workoutExercise.exerciseId
            let priorForExercise = priorBest[exerciseId] ?? [:]
            let completedSets = workoutExercise.orderedSets.filter { $0.isCompleted }

            // Max Weight PR
            if let bestWeight = completedSets.compactMap({ $0.weight }).max(),
               bestWeight > (priorForExercise[.maxWeight] ?? 0),
               let set = completedSets.first(where: { $0.weight == bestWeight }) {
                results.append(WorkoutPRResult(
                    exerciseId: exerciseId,
                    prType: .maxWeight,
                    setId: set.id,
                    previousValue: priorForExercise[.maxWeight]
                ))
            }

            // Max e1RM PR
            if let bestE1RM = completedSets.compactMap({ $0.estimated1RM }).max(),
               bestE1RM > (priorForExercise[.maxE1RM] ?? 0),
               let set = completedSets.first(where: { $0.estimated1RM == bestE1RM }) {
                results.append(WorkoutPRResult(
                    exerciseId: exerciseId,
                    prType: .maxE1RM,
                    setId: set.id,
                    previousValue: priorForExercise[.maxE1RM]
                ))
            }

            // Max Volume PR (single set)
            if let bestVolume = completedSets.compactMap({ $0.volume }).max(),
               bestVolume > (priorForExercise[.maxVolume] ?? 0),
               let set = completedSets.first(where: { $0.volume == bestVolume }) {
                results.append(WorkoutPRResult(
                    exerciseId: exerciseId,
                    prType: .maxVolume,
                    setId: set.id,
                    previousValue: priorForExercise[.maxVolume]
                ))
            }
        }

        return results
    }

    /// Count PRs achieved in a workout
    func countPRsInWorkout(_ workoutId: UUID) -> Int {
        getPRsInWorkout(workoutId).count
    }

    /// Get detailed PRs in a workout with exercise names and values for display
    /// - Parameters:
    ///   - workoutId: The workout to analyze
    ///   - exerciseNameMap: Map of exerciseId -> exercise name (pass from caller to avoid re-fetching)
    /// - Returns: Array of WorkoutSetPR with full details for UI display
    /// - Note: PRs only count if they STRICTLY beat prior best (ties are NOT PRs)
    func getWorkoutPRDetails(workoutId: UUID, exerciseNameMap: [UUID: String]) -> [WorkoutSetPR] {
        guard let workout = fetchWorkout(by: workoutId) else { return [] }

        // Fetch all completed workouts BEFORE this workout
        let priorWorkouts = fetchCompletedWorkouts(before: workout.startedAt)

        // Precompute prior best per exercise in ONE PASS (O(N) instead of O(N*M))
        var priorBest: [UUID: [PRType: Double]] = [:]
        for prior in priorWorkouts {
            for we in prior.orderedExercises {
                let exerciseId = we.exerciseId
                if priorBest[exerciseId] == nil {
                    priorBest[exerciseId] = [:]
                }

                for set in we.orderedSets where set.isCompleted {
                    if let weight = set.weight {
                        let current = priorBest[exerciseId]![.maxWeight] ?? 0
                        priorBest[exerciseId]![.maxWeight] = max(current, weight)
                    }
                    if let e1rm = set.estimated1RM {
                        let current = priorBest[exerciseId]![.maxE1RM] ?? 0
                        priorBest[exerciseId]![.maxE1RM] = max(current, e1rm)
                    }
                    if let volume = set.volume {
                        let current = priorBest[exerciseId]![.maxVolume] ?? 0
                        priorBest[exerciseId]![.maxVolume] = max(current, volume)
                    }
                }
            }
        }

        // Compare each exercise in THIS workout against precomputed map
        var results: [WorkoutSetPR] = []
        for workoutExercise in workout.orderedExercises {
            let exerciseId = workoutExercise.exerciseId
            let exerciseName = exerciseNameMap[exerciseId] ?? "Unknown Exercise"
            let priorForExercise = priorBest[exerciseId] ?? [:]
            let completedSets = workoutExercise.orderedSets.filter { $0.isCompleted }

            // Max Weight PR - find the BEST set that beats prior
            let priorWeight = priorForExercise[.maxWeight] ?? 0
            let weightPRSets = completedSets.filter { set in
                guard let weight = set.weight else { return false }
                return weight > priorWeight
            }
            if let bestWeightSet = weightPRSets.max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }),
               let weight = bestWeightSet.weight {
                results.append(WorkoutSetPR(
                    exerciseId: exerciseId,
                    exerciseName: exerciseName,
                    setId: bestWeightSet.id,
                    prType: .maxWeight,
                    value: weight,
                    previousBest: priorForExercise[.maxWeight],
                    weight: weight,
                    reps: bestWeightSet.reps
                ))
            }

            // Max e1RM PR - find the BEST set that beats prior
            let priorE1RM = priorForExercise[.maxE1RM] ?? 0
            let e1rmPRSets = completedSets.filter { set in
                guard let e1rm = set.estimated1RM else { return false }
                return e1rm > priorE1RM
            }
            if let bestE1RMSet = e1rmPRSets.max(by: { ($0.estimated1RM ?? 0) < ($1.estimated1RM ?? 0) }),
               let e1rm = bestE1RMSet.estimated1RM {
                results.append(WorkoutSetPR(
                    exerciseId: exerciseId,
                    exerciseName: exerciseName,
                    setId: bestE1RMSet.id,
                    prType: .maxE1RM,
                    value: e1rm,
                    previousBest: priorForExercise[.maxE1RM],
                    weight: bestE1RMSet.weight,
                    reps: bestE1RMSet.reps
                ))
            }

            // Max Volume PR (single set) - find the BEST set that beats prior
            let priorVolume = priorForExercise[.maxVolume] ?? 0
            let volumePRSets = completedSets.filter { set in
                guard let volume = set.volume else { return false }
                return volume > priorVolume
            }
            if let bestVolumeSet = volumePRSets.max(by: { ($0.volume ?? 0) < ($1.volume ?? 0) }),
               let volume = bestVolumeSet.volume {
                results.append(WorkoutSetPR(
                    exerciseId: exerciseId,
                    exerciseName: exerciseName,
                    setId: bestVolumeSet.id,
                    prType: .maxVolume,
                    value: volume,
                    previousBest: priorForExercise[.maxVolume],
                    weight: bestVolumeSet.weight,
                    reps: bestVolumeSet.reps
                ))
            }
        }

        return results
    }

    // MARK: - Exercise History

    /// Get exercise history (workouts where the exercise was performed)
    func getExerciseHistory(exerciseId: UUID) -> [ExerciseHistorySummary] {
        let completedWorkouts = fetchCompletedWorkouts()

        var summaries: [ExerciseHistorySummary] = []
        for workout in completedWorkouts {
            for we in workout.orderedExercises where we.exerciseId == exerciseId {
                let completedSets = we.orderedSets.filter { $0.isCompleted }
                guard !completedSets.isEmpty else { continue }

                summaries.append(ExerciseHistorySummary(
                    workoutId: workout.id,
                    workoutTitle: workout.title,
                    date: workout.startedAt,
                    setCount: completedSets.count,
                    totalVolume: we.totalVolume,
                    bestWeight: completedSets.compactMap { $0.weight }.max(),
                    bestE1RM: completedSets.compactMap { $0.estimated1RM }.max()
                ))
            }
        }

        return summaries.sorted { $0.date > $1.date }
    }

    // MARK: - Weekly Stats

    /// Get weekly stats for the history view
    func getWeeklyStats(sessionsGoal: Int = 4) -> HistoryWeeklyStats {
        let calendar = Calendar.current
        let now = Date()

        // Get start of this week (Monday)
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return HistoryWeeklyStats(
                sessionsCompleted: 0,
                sessionsGoal: sessionsGoal,
                totalVolume: 0,
                volumeTrend: 0,
                totalTime: 0
            )
        }

        // Get start of last week
        let startOfLastWeek = calendar.date(byAdding: .day, value: -7, to: startOfWeek) ?? startOfWeek

        // Fetch this week's workouts
        let thisWeekWorkouts = fetchCompletedWorkouts(from: startOfWeek, to: now)

        // Fetch last week's workouts
        let lastWeekWorkouts = fetchCompletedWorkouts(from: startOfLastWeek, to: startOfWeek)

        // Calculate this week's stats
        let thisWeekVolume = calculateTotalVolume(for: thisWeekWorkouts)
        let thisWeekTime = calculateTotalTime(for: thisWeekWorkouts)

        // Calculate last week's volume for trend
        let lastWeekVolume = calculateTotalVolume(for: lastWeekWorkouts)

        // Calculate trend percentage
        let volumeTrend: Double
        if lastWeekVolume > 0 {
            volumeTrend = ((thisWeekVolume - lastWeekVolume) / lastWeekVolume) * 100
        } else if thisWeekVolume > 0 {
            volumeTrend = 100  // 100% increase from zero
        } else {
            volumeTrend = 0
        }

        return HistoryWeeklyStats(
            sessionsCompleted: thisWeekWorkouts.count,
            sessionsGoal: sessionsGoal,
            totalVolume: thisWeekVolume,
            volumeTrend: volumeTrend,
            totalTime: thisWeekTime
        )
    }

    /// Get section stats (session count and total volume) for a group of workouts
    func getSectionStats(workoutIds: [UUID]) -> (sessionCount: Int, totalVolume: Double) {
        let workouts = workoutIds.compactMap { fetchWorkout(by: $0) }
        let totalVolume = calculateTotalVolume(for: workouts)
        return (workouts.count, totalVolume)
    }

    // MARK: - Private Helpers

    private func fetchCompletedWorkouts(from startDate: Date, to endDate: Date) -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endedAt != nil && $0.startedAt >= startDate && $0.startedAt < endDate },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func calculateTotalVolume(for workouts: [Workout]) -> Double {
        workouts.reduce(0) { total, workout in
            total + workout.orderedExercises.reduce(0) { $0 + $1.totalVolume }
        }
    }

    private func calculateTotalTime(for workouts: [Workout]) -> TimeInterval {
        workouts.reduce(0) { total, workout in
            total + workout.duration
        }
    }

    private func fetchWorkout(by id: UUID) -> Workout? {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchCompletedWorkouts() -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endedAt != nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchCompletedWorkouts(before date: Date) -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endedAt != nil && $0.startedAt < date },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func calculatePRs(for exerciseId: UUID, fromWorkouts workouts: [Workout]) -> [PRType: PersonalRecord] {
        var prs: [PRType: PersonalRecord] = [:]

        for workout in workouts {
            for we in workout.orderedExercises where we.exerciseId == exerciseId {
                for set in we.orderedSets where set.isCompleted {
                    // Max Weight
                    if let weight = set.weight {
                        if prs[.maxWeight] == nil || weight > prs[.maxWeight]!.value {
                            prs[.maxWeight] = PersonalRecord(
                                type: .maxWeight,
                                value: weight,
                                setId: set.id,
                                workoutId: workout.id,
                                achievedAt: workout.startedAt
                            )
                        }
                    }

                    // Max e1RM
                    if let e1rm = set.estimated1RM {
                        if prs[.maxE1RM] == nil || e1rm > prs[.maxE1RM]!.value {
                            prs[.maxE1RM] = PersonalRecord(
                                type: .maxE1RM,
                                value: e1rm,
                                setId: set.id,
                                workoutId: workout.id,
                                achievedAt: workout.startedAt
                            )
                        }
                    }

                    // Max Volume
                    if let volume = set.volume {
                        if prs[.maxVolume] == nil || volume > prs[.maxVolume]!.value {
                            prs[.maxVolume] = PersonalRecord(
                                type: .maxVolume,
                                value: volume,
                                setId: set.id,
                                workoutId: workout.id,
                                achievedAt: workout.startedAt
                            )
                        }
                    }
                }
            }
        }

        return prs
    }

    // MARK: - Dashboard Data

    /// Fetch all dashboard data in a single efficient call
    func getDashboardData(sessionsGoal: Int) -> DashboardData {
        let calendar = Calendar.current
        let now = Date()

        // Week intervals (Monday-start, ISO)
        let thisWeekInterval = currentWeekInterval(now: now, calendar: calendar)
        let lastWeekInterval = previousWeekInterval(from: thisWeekInterval, calendar: calendar)

        // Fetch data with predicates + limits (NO fetch all)
        let thisWeekWorkouts = fetchWorkoutsInInterval(thisWeekInterval)
        let lastWeekWorkouts = fetchWorkoutsInInterval(lastWeekInterval)
        let lastWorkout = fetchLastWorkout()
        let recentWorkouts = fetchRecentWorkouts(days: 14)  // For recovery only

        // Compute derived data
        let stats = computeDashboardStats(
            thisWeekWorkouts: thisWeekWorkouts,
            lastWeekWorkouts: lastWeekWorkouts,
            sessionsGoal: sessionsGoal
        )
        let weeklyVolume = computeWeeklyVolumeByDay(
            workouts: thisWeekWorkouts,
            weekStart: thisWeekInterval.start,
            calendar: calendar
        )
        let recovery = computeRecovery(recentWorkouts: recentWorkouts)
        let hasAnyWorkouts = fetchHasAnyWorkouts()
        let latestPR = fetchLatestPRData()

        // Map last workout to display data
        let lastWorkoutData: LastWorkoutData? = lastWorkout.map { workout in
            let muscleGroup = primaryMuscleGroup(for: workout)
            let prCount = countPRsInWorkout(workout.id)
            return LastWorkoutData(
                id: workout.id,
                muscleGroup: muscleGroup,
                date: workout.startedAt,
                durationSeconds: Int(workout.duration),
                volume: workout.totalVolume,
                prCount: prCount
            )
        }

        return DashboardData(
            stats: stats,
            weeklyVolumeByDay: weeklyVolume,
            lastWorkout: lastWorkoutData,
            latestPR: latestPR,
            recovery: recovery,
            hasAnyWorkouts: hasAnyWorkouts
        )
    }

    // MARK: - Dashboard Private Helpers

    /// Monday-start week interval (ISO week)
    private func currentWeekInterval(now: Date, calendar: Calendar) -> DateInterval {
        var cal = calendar
        cal.firstWeekday = 2  // Monday = 2
        guard let interval = cal.dateInterval(of: .weekOfYear, for: now) else {
            return DateInterval(start: now, duration: 0)
        }
        return interval
    }

    private func previousWeekInterval(from current: DateInterval, calendar: Calendar) -> DateInterval {
        let previousStart = calendar.date(byAdding: .day, value: -7, to: current.start)!
        return DateInterval(start: previousStart, end: current.start)
    }

    private func fetchWorkoutsInInterval(_ interval: DateInterval) -> [Workout] {
        let startDate = interval.start
        let endDate = interval.end
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate {
                $0.endedAt != nil &&
                $0.startedAt >= startDate &&
                $0.startedAt < endDate
            },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchLastWorkout() -> Workout? {
        var descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endedAt != nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchRecentWorkouts(days: Int) -> [Workout] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endedAt != nil && $0.startedAt >= cutoff },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchHasAnyWorkouts() -> Bool {
        var descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endedAt != nil }
        )
        descriptor.fetchLimit = 1
        return ((try? modelContext.fetch(descriptor)) ?? []).count > 0
    }

    private func fetchLatestPRData() -> LatestPRData? {
        // Get most recent workouts with PRs
        let workouts = fetchCompletedWorkouts()  // Already sorted recent first
        let exercises = fetchExercises()
        let nameMap = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0.name) })

        for workout in workouts.prefix(20) {  // Check last 20 max for performance
            let prs = getWorkoutPRDetails(workoutId: workout.id, exerciseNameMap: nameMap)
            // Prefer maxWeight PRs for display, but take any PR type
            if let pr = prs.filter({ $0.prType == .maxWeight }).first ?? prs.first {
                return LatestPRData(
                    id: pr.setId,
                    exerciseName: pr.exerciseName,
                    prType: pr.prType,
                    weight: pr.weight ?? 0,
                    reps: pr.reps,
                    achievedAt: workout.startedAt
                )
            }
        }

        return nil
    }

    private func computeDashboardStats(
        thisWeekWorkouts: [Workout],
        lastWeekWorkouts: [Workout],
        sessionsGoal: Int
    ) -> DashboardStats {
        let thisWeekVolume = thisWeekWorkouts.reduce(0) { $0 + $1.totalVolume }
        let lastWeekVolume = lastWeekWorkouts.reduce(0) { $0 + $1.totalVolume }

        // Trend calculation with zero handling
        let trend: TrendDisplay
        if lastWeekVolume == 0 && thisWeekVolume > 0 {
            trend = .new
        } else if lastWeekVolume == 0 && thisWeekVolume == 0 {
            trend = .none
        } else {
            let pct = ((thisWeekVolume - lastWeekVolume) / lastWeekVolume) * 100
            trend = .percentage(pct)
        }

        return DashboardStats(
            weeklyVolume: thisWeekVolume,
            volumeTrend: trend,
            sessionsCompleted: thisWeekWorkouts.count,
            sessionsGoal: sessionsGoal
        )
    }

    private func computeWeeklyVolumeByDay(
        workouts: [Workout],
        weekStart: Date,
        calendar: Calendar
    ) -> [Double] {
        var volumeByDay = [Double](repeating: 0, count: 7)  // Mon=0, Sun=6

        for workout in workouts {
            let daysSinceStart = calendar.dateComponents([.day], from: weekStart, to: workout.startedAt).day ?? 0
            let index = min(max(daysSinceStart, 0), 6)
            volumeByDay[index] += workout.totalVolume
        }

        return volumeByDay
    }

    private func computeRecovery(recentWorkouts: [Workout]) -> [RecoveryItem] {
        let exercises = fetchExercises()
        let exerciseMap = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

        // Track last trained date per muscle group
        var lastTrainedAt: [MuscleGroup: Date] = [:]

        for workout in recentWorkouts {
            for we in workout.orderedExercises {
                guard let exercise = exerciseMap[we.exerciseId] else { continue }
                let muscle = exercise.muscleGroup
                guard muscle != .fullBody else { continue }  // Skip fullBody

                if lastTrainedAt[muscle] == nil || workout.startedAt > lastTrainedAt[muscle]! {
                    lastTrainedAt[muscle] = workout.startedAt
                }
            }
        }

        // Calculate recovery % using piecewise rule
        let now = Date()
        var items: [RecoveryItem] = []

        for (muscle, lastDate) in lastTrainedAt {
            let hoursSince = Int(now.timeIntervalSince(lastDate) / 3600)

            // Recovery formula:
            // 0-24h = 0-40%, 24-48h = 40-80%, 48-72h = 80-100%, 72h+ = 100%
            let recovered: Double
            switch hoursSince {
            case 0..<24:
                recovered = Double(hoursSince) / 24.0 * 0.4
            case 24..<48:
                recovered = 0.4 + (Double(hoursSince - 24) / 24.0 * 0.4)
            case 48..<72:
                recovered = 0.8 + (Double(hoursSince - 48) / 24.0 * 0.2)
            default:
                recovered = 1.0
            }

            items.append(RecoveryItem(muscle: muscle, recovered: recovered, hoursSinceTraining: hoursSince))
        }

        // Return up to 2 muscles with LOWEST recovered%
        return Array(items.sorted { $0.recovered < $1.recovered }.prefix(2))
    }

    private func primaryMuscleGroup(for workout: Workout) -> MuscleGroup? {
        let exercises = fetchExercises()
        let exerciseMap = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

        var muscleCount: [MuscleGroup: Int] = [:]
        for we in workout.orderedExercises {
            if let exercise = exerciseMap[we.exerciseId] {
                muscleCount[exercise.muscleGroup, default: 0] += 1
            }
        }
        return muscleCount.max(by: { $0.value < $1.value })?.key
    }

    private func fetchExercises() -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
