import SwiftUI
import SwiftData

@MainActor
@Observable
final class OnboardingViewModel {
    var name: String = ""
    var primaryGoal: PrimaryGoal = .buildSavings
    var baselineStress: Double = 5
    var nameError: String? = nil

    func createProfile(modelContext: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameError = "Please enter your name."
            return
        }
        nameError = nil
        let profile = UserProfile(
            name: trimmed,
            primaryGoal: primaryGoal,
            baselineStress: Int(baselineStress)
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
}
