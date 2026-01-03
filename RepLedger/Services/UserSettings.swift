import Foundation
import SwiftUI

/// Manages user preferences and settings.
/// Uses UserDefaults for persistence.
@Observable
final class UserSettings {
    // MARK: - Singleton

    static let shared = UserSettings()

    // MARK: - Keys

    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let liftingUnit = "liftingUnit"
        static let bodyweightUnit = "bodyweightUnit"
        static let restTimerDuration = "restTimerDuration"
        static let restTimerAutoStart = "restTimerAutoStart"
        static let selectedTheme = "selectedTheme"
    }

    // MARK: - Defaults

    private enum Defaults {
        static let restTimerDuration = 90  // seconds
        static let restTimerAutoStart = true
    }

    // MARK: - Properties

    /// Whether onboarding has been completed
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    /// Lifting weight unit (kg/lb)
    var liftingUnit: WeightUnit {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Keys.liftingUnit),
                  let unit = WeightUnit(rawValue: rawValue) else {
                return .kg
            }
            return unit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.liftingUnit)
        }
    }

    /// Bodyweight display unit (kg/lb/stone+lb)
    var bodyweightUnit: BodyweightUnit {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Keys.bodyweightUnit),
                  let unit = BodyweightUnit(rawValue: rawValue) else {
                return .kg
            }
            return unit
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.bodyweightUnit)
        }
    }

    /// Rest timer duration in seconds
    var restTimerDuration: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.restTimerDuration)
            return value > 0 ? value : Defaults.restTimerDuration
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.restTimerDuration)
        }
    }

    /// Whether rest timer auto-starts after completing a set
    var restTimerAutoStart: Bool {
        get {
            // Check if key exists, otherwise use default
            if UserDefaults.standard.object(forKey: Keys.restTimerAutoStart) == nil {
                return Defaults.restTimerAutoStart
            }
            return UserDefaults.standard.bool(forKey: Keys.restTimerAutoStart)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.restTimerAutoStart)
        }
    }

    /// Selected theme ID
    var selectedTheme: ThemeID {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: Keys.selectedTheme),
                  let themeId = ThemeID(rawValue: rawValue) else {
                return .obsidian
            }
            return themeId
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.selectedTheme)
        }
    }

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

    private init() {}

    // MARK: - Reset

    /// Reset all settings to defaults
    func resetToDefaults() {
        hasCompletedOnboarding = false
        liftingUnit = .kg
        bodyweightUnit = .kg
        restTimerDuration = Defaults.restTimerDuration
        restTimerAutoStart = Defaults.restTimerAutoStart
        selectedTheme = .obsidian
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
