import Foundation

enum PrimaryGoal: String, CaseIterable, Codable {
    case reduceStressSpending = "Reduce Stress Spending"
    case buildSavings         = "Build Savings"
    case payDownDebt          = "Pay Down Debt"
}

enum SpendingUrge: String, CaseIterable, Codable {
    case none   = "None"
    case mild   = "Mild"
    case strong = "Strong"
}

enum GoalToday: String, CaseIterable, Codable {
    case save         = "Save"
    case avoidImpulse = "Avoid Impulse"
    case payDebt      = "Pay Debt"
    case other        = "Other"
}
