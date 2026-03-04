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

// MARK: - Money Triggers (Check-In Step 5)
enum MoneyEmotion: String, CaseIterable, Codable {
    case anxious  = "Anxious"
    case excited  = "Excited"
    case bored    = "Bored"
    case sad      = "Sad"
    case happy    = "Happy"
    case stressed = "Stressed"

    var icon: String {
        switch self {
        case .anxious:  return "😰"
        case .excited:  return "🤩"
        case .bored:    return "😑"
        case .sad:      return "😔"
        case .happy:    return "😊"
        case .stressed: return "😤"
        }
    }
}

enum SpendingCategory: String, CaseIterable, Codable {
    case clothes       = "Clothes"
    case food          = "Food & Dining"
    case tech          = "Tech & Gadgets"
    case entertainment = "Entertainment"
    case home          = "Home & Living"
    case beauty        = "Beauty"
    case other         = "Other"

    var icon: String {
        switch self {
        case .clothes:       return "👗"
        case .food:          return "🍔"
        case .tech:          return "💻"
        case .entertainment: return "🎬"
        case .home:          return "🏠"
        case .beauty:        return "💄"
        case .other:         return "📦"
        }
    }
}

enum TriggerTime: String, CaseIterable, Codable {
    case morning   = "Morning"
    case afternoon = "Afternoon"
    case evening   = "Evening"
    case night     = "Night"

    var icon: String {
        switch self {
        case .morning:   return "🌅"
        case .afternoon: return "☀️"
        case .evening:   return "🌆"
        case .night:     return "🌙"
        }
    }
}
