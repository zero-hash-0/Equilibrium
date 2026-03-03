import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var primaryGoalRaw: String
    var baselineStress: Int
    var createdAt: Date
    var updatedAt: Date

    init(name: String, primaryGoal: PrimaryGoal, baselineStress: Int) {
        self.id             = UUID()
        self.name           = name
        self.primaryGoalRaw = primaryGoal.rawValue
        self.baselineStress = baselineStress
        self.createdAt      = Date()
        self.updatedAt      = Date()
    }

    var primaryGoal: PrimaryGoal {
        get { PrimaryGoal(rawValue: primaryGoalRaw) ?? .buildSavings }
        set { primaryGoalRaw = newValue.rawValue; updatedAt = Date() }
    }
}
