import Foundation
import SwiftData

@Model
final class CheckIn {
    @Attribute(.unique) var id: UUID
    var date: Date
    var dayKey: String
    var stressLevel: Int
    var spendingUrgeRaw: String
    var sleepQuality: Int?
    var goalTodayRaw: String
    var note: String?
    var wellnessScore: Int
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \AIInsight.checkIn)
    var insight: AIInsight?

    init(stressLevel: Int, spendingUrge: SpendingUrge, sleepQuality: Int?,
         goalToday: GoalToday, note: String?, wellnessScore: Int) {
        self.id             = UUID()
        self.date           = Date()
        self.dayKey         = DateHelpers.todayKey()
        self.stressLevel    = stressLevel
        self.spendingUrgeRaw = spendingUrge.rawValue
        self.sleepQuality   = sleepQuality
        self.goalTodayRaw   = goalToday.rawValue
        self.note           = note
        self.wellnessScore  = wellnessScore
        self.createdAt      = Date()
    }

    var spendingUrge: SpendingUrge {
        get { SpendingUrge(rawValue: spendingUrgeRaw) ?? .none }
        set { spendingUrgeRaw = newValue.rawValue }
    }

    var goalToday: GoalToday {
        get { GoalToday(rawValue: goalTodayRaw) ?? .other }
        set { goalTodayRaw = newValue.rawValue }
    }
}
