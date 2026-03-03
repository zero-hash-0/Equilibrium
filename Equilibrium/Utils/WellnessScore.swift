import Foundation

enum WellnessScore {
    static func compute(stressLevel: Int, spendingUrge: SpendingUrge, sleepQuality: Int?) -> Int {
        var score = 50
        score += (6 - stressLevel) * 4
        switch spendingUrge {
        case .none:   score += 12
        case .mild:   score += 4
        case .strong: score -= 10
        }
        if let sleep = sleepQuality {
            score += (sleep - 3) * 5
        }
        return max(0, min(100, score))
    }

    static func explanation(for score: Int) -> String {
        switch score {
        case 80...:    return "Excellent balance today. Keep it up!"
        case 65..<80:  return "Good financial wellness. Small wins add up."
        case 50..<65:  return "Moderate — one mindful choice can shift this."
        case 35..<50:  return "Some stress present. Be kind to yourself."
        default:       return "High stress today. One step at a time."
        }
    }

    static func label(for score: Int) -> String {
        switch score {
        case 75...:   return "Excellent"
        case 55..<75: return "Good"
        case 40..<55: return "Moderate"
        case 25..<40: return "Stressed"
        default:      return "High Stress"
        }
    }

    static func color(for score: Int) -> String {
        // Return semantic name used in UI
        switch score {
        case 65...:   return "mint"
        case 45..<65: return "yellow"
        default:      return "orange"
        }
    }
}
