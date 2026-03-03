import Foundation
import SwiftData

enum SpendingUrge: String, Codable, CaseIterable {
    case none   = "None"
    case mild   = "Mild"
    case strong = "Strong"
}

enum DailyGoal: String, Codable, CaseIterable {
    case save          = "Save"
    case avoidImpulse  = "Avoid impulse"
    case payDebt       = "Pay debt"
    case other         = "Other"
}

@Model
final class CheckIn {
    var id: UUID
    var date: Date
    var stressLevel: Int       // 1-10
    var spendingUrge: String   // SpendingUrge.rawValue
    var sleepQuality: Int?     // 1-5, optional
    var goalToday: String      // DailyGoal.rawValue
    var note: String?
    var wellnessScore: Int     // 0-100 computed at save time
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var insight: AIInsight?

    init(stressLevel: Int,
         spendingUrge: SpendingUrge,
         sleepQuality: Int?,
         goalToday: DailyGoal,
         note: String?) {
        self.id            = UUID()
        self.date          = Date()
        self.stressLevel   = stressLevel
        self.spendingUrge  = spendingUrge.rawValue
        self.sleepQuality  = sleepQuality
        self.goalToday     = goalToday.rawValue
        self.note          = note
        self.wellnessScore = WellnessScoreCalculator.compute(
            stress: stressLevel,
            urge: spendingUrge,
            sleep: sleepQuality
        )
        self.createdAt     = Date()
    }

    var spendingUrgeEnum: SpendingUrge {
        SpendingUrge(rawValue: spendingUrge) ?? .none
    }

    var goalTodayEnum: DailyGoal {
        DailyGoal(rawValue: goalToday) ?? .other
    }
}
