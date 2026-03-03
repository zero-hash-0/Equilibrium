import SwiftUI
import SwiftData

@Observable
final class CheckInViewModel {
    // Step state
    var currentStep: Int = 1
    let totalSteps = 4

    // Step 1
    var stressLevel: Double = 5

    // Step 2
    var spendingUrge: SpendingUrge = .none
    var note: String = ""

    // Step 3
    var sleepQualityEnabled = false
    var sleepQuality: Double = 3

    // Step 4
    var goalToday: DailyGoal = .save

    // Result
    var savedCheckIn: CheckIn? = nil

    var progress: Double { Double(currentStep) / Double(totalSteps) }

    func nextStep() {
        if currentStep < totalSteps { currentStep += 1 }
    }
    func previousStep() {
        if currentStep > 1 { currentStep -= 1 }
    }

    func submit(context: ModelContext) {
        let checkIn = CheckIn(
            stressLevel:   Int(stressLevel),
            spendingUrge:  spendingUrge,
            sleepQuality:  sleepQualityEnabled ? Int(sleepQuality) : nil,
            goalToday:     goalToday,
            note:          note.isEmpty ? nil : note
        )
        context.insert(checkIn)
        try? context.save()
        savedCheckIn = checkIn
    }
}
