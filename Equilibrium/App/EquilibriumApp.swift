import SwiftUI
import SwiftData

@main
struct EquilibriumApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([UserProfile.self, CheckIn.self, AIInsight.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData ModelContainer failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            OnboardingGateView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}
