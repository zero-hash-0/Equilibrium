import Foundation
import SwiftData

enum PrimaryGoal: String, Codable, CaseIterable {
    case reduceStressSpending = "Reduce stress spending"
    case buildSavings         = "Build savings"
    case payDownDebt          = "Pay down debt"
}

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var primaryGoal: String
    var baselineStress: Int    // 1-10
    var createdAt: Date
    var updatedAt: Date

    init(name: String, primaryGoal: PrimaryGoal, baselineStress: Int) {
        self.id             = UUID()
        self.name           = name
        self.primaryGoal    = primaryGoal.rawValue
        self.baselineStress = baselineStress
        self.createdAt      = Date()
        self.updatedAt      = Date()
    }

    var primaryGoalEnum: PrimaryGoal {
        PrimaryGoal(rawValue: primaryGoal) ?? .buildSavings
    }
}
