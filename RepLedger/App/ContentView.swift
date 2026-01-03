import SwiftUI

struct ContentView: View {
    // TODO: Milestone 1 - Check hasCompletedOnboarding and show OnboardingView if needed
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            // TODO: Milestone 1 - Replace with OnboardingView
            VStack(spacing: 24) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)

                Text("RepLedger")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Premium strength training tracker")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Get Started") {
                    // TODO: Replace with proper onboarding flow
                    hasCompletedOnboarding = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    // TODO: Milestone 5 - Add isCoach check for Coach tab visibility

    var body: some View {
        TabView {
            DashboardPlaceholderView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            HistoryPlaceholderView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            StartPlaceholderView()
                .tabItem {
                    Label("Start", systemImage: "plus.circle.fill")
                }

            ExercisesPlaceholderView()
                .tabItem {
                    Label("Exercises", systemImage: "dumbbell.fill")
                }

            SettingsPlaceholderView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// MARK: - Placeholder Views
struct DashboardPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Dashboard")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Your training overview will appear here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct HistoryPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No Workouts Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Complete your first workout to see it here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("History")
        }
    }
}

struct StartPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)
                Text("Start Workout")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Begin an empty workout or choose a template")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // TODO: Milestone 2 - Add Quick Start and Template selection
                Button("Quick Start") {
                    // TODO: Start empty workout
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .navigationTitle("Start")
        }
    }
}

struct ExercisesPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("Exercise Library")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Browse and search exercises")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Exercises")
        }
    }
}

struct SettingsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Label("Units", systemImage: "scalemass.fill")
                    Label("Theme", systemImage: "paintbrush.fill")
                    Label("Rest Timer", systemImage: "timer")
                }

                Section("Pro") {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                    Label("Backup & Sync", systemImage: "icloud.fill")
                }

                Section("Account") {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
