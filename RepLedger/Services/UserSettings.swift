import Foundation
import SwiftUI

/// Manages user preferences and settings.
/// Uses UserDefaults for persistence with @Observable stored properties for SwiftUI reactivity.
@Observable
final class UserSettings {
    // MARK: - Singleton

    static let shared = UserSettings()

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let userName = "userName"
        static let liftingUnit = "liftingUnit"
        static let bodyweightUnit = "bodyweightUnit"
        static let restTimerDuration = "restTimerDuration"
        static let restTimerAutoStart = "restTimerAutoStart"
        static let selectedTheme = "selectedTheme"
        static let completedWorkoutCount = "completedWorkoutCount"
        static let hasShownProUpsell = "hasShownProUpsell"
        static let hasSeenCoachComingSoon = "hasSeenCoachComingSoon"
        static let weeklySessionsGoal = "weeklySessionsGoal"
        #if DEBUG
        static let showCoachPreviewData = "showCoachPreviewData"
        #endif
    }

    // MARK: - Defaults

    private enum Defaults {
        static let restTimerDuration = 90  // seconds
        static let restTimerAutoStart = true
        static let weeklySessionsGoal = 4  // 3-7 range
    }

    // MARK: - Stored Properties (for @Observable tracking)

    /// Whether onboarding has been completed
    var hasCompletedOnboarding: Bool {
        didSet {
            guard oldValue != hasCompletedOnboarding else { return }
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
        }
    }

    /// User's display name (optional, for personalized greeting)
    var userName: String {
        didSet {
            guard oldValue != userName else { return }
            UserDefaults.standard.set(userName, forKey: Keys.userName)
        }
    }

    /// Lifting weight unit (kg/lb)
    var liftingUnit: WeightUnit {
        didSet {
            guard oldValue != liftingUnit else { return }
            UserDefaults.standard.set(liftingUnit.rawValue, forKey: Keys.liftingUnit)
        }
    }

    /// Bodyweight display unit (kg/lb/stone+lb)
    var bodyweightUnit: BodyweightUnit {
        didSet {
            guard oldValue != bodyweightUnit else { return }
            UserDefaults.standard.set(bodyweightUnit.rawValue, forKey: Keys.bodyweightUnit)
        }
    }

    /// Rest timer duration in seconds
    var restTimerDuration: Int {
        didSet {
            guard oldValue != restTimerDuration else { return }
            UserDefaults.standard.set(restTimerDuration, forKey: Keys.restTimerDuration)
        }
    }

    /// Whether rest timer auto-starts after completing a set
    var restTimerAutoStart: Bool {
        didSet {
            guard oldValue != restTimerAutoStart else { return }
            UserDefaults.standard.set(restTimerAutoStart, forKey: Keys.restTimerAutoStart)
        }
    }

    /// Selected theme ID
    var selectedTheme: ThemeID {
        didSet {
            guard oldValue != selectedTheme else { return }
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Keys.selectedTheme)
        }
    }

    /// Number of completed workouts (for soft upsell trigger)
    var completedWorkoutCount: Int {
        didSet {
            guard oldValue != completedWorkoutCount else { return }
            UserDefaults.standard.set(completedWorkoutCount, forKey: Keys.completedWorkoutCount)
        }
    }

    /// Whether the Pro upsell has been shown (show only once)
    var hasShownProUpsell: Bool {
        didSet {
            guard oldValue != hasShownProUpsell else { return }
            UserDefaults.standard.set(hasShownProUpsell, forKey: Keys.hasShownProUpsell)
        }
    }

    /// Whether the Coach "Coming Soon" sheet has been shown (show only once)
    var hasSeenCoachComingSoon: Bool {
        didSet {
            guard oldValue != hasSeenCoachComingSoon else { return }
            UserDefaults.standard.set(hasSeenCoachComingSoon, forKey: Keys.hasSeenCoachComingSoon)
        }
    }

    /// Weekly sessions goal for dashboard (3-7 range)
    var weeklySessionsGoal: Int {
        didSet {
            guard oldValue != weeklySessionsGoal else { return }
            // Clamp to valid range
            let clamped = min(max(weeklySessionsGoal, 3), 7)
            if clamped != weeklySessionsGoal {
                weeklySessionsGoal = clamped
            }
            UserDefaults.standard.set(weeklySessionsGoal, forKey: Keys.weeklySessionsGoal)
        }
    }

    #if DEBUG
    /// Whether to show preview data in Coach tab (DEBUG only)
    var showCoachPreviewData: Bool {
        didSet {
            guard oldValue != showCoachPreviewData else { return }
            UserDefaults.standard.set(showCoachPreviewData, forKey: Keys.showCoachPreviewData)
        }
    }
    #endif

    // MARK: - Computed Helpers

    /// Formatted rest timer duration string
    var formattedRestDuration: String {
        let minutes = restTimerDuration / 60
        let seconds = restTimerDuration % 60
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }

    /// Common rest timer presets
    static let restTimerPresets: [Int] = [30, 60, 90, 120, 180, 300]

    // MARK: - Initialization

    private init() {
        // Load from UserDefaults or use defaults
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        self.userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""

        if let liftingRaw = UserDefaults.standard.string(forKey: Keys.liftingUnit),
           let unit = WeightUnit(rawValue: liftingRaw) {
            self.liftingUnit = unit
        } else {
            self.liftingUnit = .kg
        }

        if let bodyweightRaw = UserDefaults.standard.string(forKey: Keys.bodyweightUnit),
           let unit = BodyweightUnit(rawValue: bodyweightRaw) {
            self.bodyweightUnit = unit
        } else {
            self.bodyweightUnit = .kg
        }

        let storedRestDuration = UserDefaults.standard.integer(forKey: Keys.restTimerDuration)
        self.restTimerDuration = storedRestDuration > 0 ? storedRestDuration : Defaults.restTimerDuration

        if UserDefaults.standard.object(forKey: Keys.restTimerAutoStart) != nil {
            self.restTimerAutoStart = UserDefaults.standard.bool(forKey: Keys.restTimerAutoStart)
        } else {
            self.restTimerAutoStart = Defaults.restTimerAutoStart
        }

        if let themeRaw = UserDefaults.standard.string(forKey: Keys.selectedTheme),
           let themeId = ThemeID(rawValue: themeRaw) {
            self.selectedTheme = themeId
        } else {
            self.selectedTheme = .obsidian
        }

        self.completedWorkoutCount = UserDefaults.standard.integer(forKey: Keys.completedWorkoutCount)
        self.hasShownProUpsell = UserDefaults.standard.bool(forKey: Keys.hasShownProUpsell)
        self.hasSeenCoachComingSoon = UserDefaults.standard.bool(forKey: Keys.hasSeenCoachComingSoon)

        let storedGoal = UserDefaults.standard.integer(forKey: Keys.weeklySessionsGoal)
        // If unset (0) or out of range, use default
        if storedGoal >= 3 && storedGoal <= 7 {
            self.weeklySessionsGoal = storedGoal
        } else {
            self.weeklySessionsGoal = Defaults.weeklySessionsGoal
        }

        #if DEBUG
        self.showCoachPreviewData = UserDefaults.standard.bool(forKey: Keys.showCoachPreviewData)
        #endif
    }

    // MARK: - Reset

    /// Reset all settings to defaults
    func resetToDefaults() {
        hasCompletedOnboarding = false
        userName = ""
        liftingUnit = .kg
        bodyweightUnit = .kg
        restTimerDuration = Defaults.restTimerDuration
        restTimerAutoStart = Defaults.restTimerAutoStart
        selectedTheme = .obsidian
        completedWorkoutCount = 0
        hasShownProUpsell = false
        hasSeenCoachComingSoon = false
        weeklySessionsGoal = Defaults.weeklySessionsGoal
        #if DEBUG
        showCoachPreviewData = false
        #endif
    }
}

// MARK: - Environment Key

private struct UserSettingsKey: EnvironmentKey {
    static let defaultValue = UserSettings.shared
}

extension EnvironmentValues {
    var userSettings: UserSettings {
        get { self[UserSettingsKey.self] }
        set { self[UserSettingsKey.self] = newValue }
    }
}
