import SwiftUI
import SwiftData

@main
struct RepLedgerApp: App {
    // Theme manager for global theme state
    @State private var themeManager = ThemeManager()

    // TODO: Milestone 4 - Initialize PurchaseManager and EntitlementsService

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Template.self,
            Workout.self,
            WorkoutExercise.self,
            SetEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
