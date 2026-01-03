import SwiftUI
import SwiftData

@main
struct RepLedgerApp: App {
    // TODO: Milestone 1 - Initialize ThemeManager and inject into environment
    // TODO: Milestone 4 - Initialize PurchaseManager and EntitlementsService

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // TODO: Milestone 1 - Add SwiftData models here
            // Exercise.self,
            // Template.self,
            // Workout.self,
            // WorkoutExercise.self,
            // SetEntry.self,
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
        }
        .modelContainer(sharedModelContainer)
    }
}
