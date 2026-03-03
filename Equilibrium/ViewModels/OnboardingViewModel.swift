import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    var name: String = ""
    var selectedGoal: PrimaryGoal = .buildSavings
    var baselineStress: Double = 5
    var nameError: String? = nil

    func validate() -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            nameError = "Please enter your name."
            return false
        }
        nameError = nil
        return true
    }

    func saveProfile(context: ModelContext) {
        guard validate() else { return }
        let profile = UserProfile(
            name: name.trimmingCharacters(in: .whitespaces),
            primaryGoal: selectedGoal,
            baselineStress: Int(baselineStress)
        )
        context.insert(profile)
        try? context.save()
    }
}
