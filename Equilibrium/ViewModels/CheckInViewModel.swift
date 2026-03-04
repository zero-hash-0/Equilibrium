import SwiftUI
import SwiftData

@MainActor
@Observable
final class CheckInViewModel {
    var step: Int = 1
    let totalSteps = 5

    // Step 1-4 values
    var stressLevel: Double = 5
    var spendingUrge: SpendingUrge = .none
    var note: String = ""
    var sleepEnabled: Bool = false
    var sleepQuality: Double = 3
    var goalToday: GoalToday = .save

    // Step 5: Money Triggers
    var selectedMoneyTrigger: ImpulseTrigger? = nil
    var selectedTriggerTime: TriggerTime? = nil
    var selectedEmotion: MoneyEmotion? = nil
    var selectedCategory: SpendingCategory? = nil

    var canGoBack: Bool { step > 1 }
    var isLastStep: Bool { step == totalSteps }
    var progress: Double { Double(step) / Double(totalSteps) }

    func nextStep() { if step < totalSteps { step += 1 } }
    func prevStep() { if step > 1 { step -= 1 } }

    func submit(modelContext: ModelContext) -> CheckIn {
        let score = WellnessScore.compute(
            stressLevel: Int(stressLevel),
            spendingUrge: spendingUrge,
            sleepQuality: sleepEnabled ? Int(sleepQuality) : nil
        )
        let checkIn = CheckIn(
            stressLevel: Int(stressLevel),
            spendingUrge: spendingUrge,
            sleepQuality: sleepEnabled ? Int(sleepQuality) : nil,
            goalToday: goalToday,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            wellnessScore: score
        )
        // Save money trigger fields
        checkIn.moneyTriggerRaw = selectedMoneyTrigger?.rawValue
        checkIn.moneyEmotionRaw = selectedEmotion?.rawValue
        checkIn.spendingCategoryRaw = selectedCategory?.rawValue
        checkIn.triggerTimeRaw = selectedTriggerTime?.rawValue

        modelContext.insert(checkIn)
        try? modelContext.save()
        return checkIn
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
