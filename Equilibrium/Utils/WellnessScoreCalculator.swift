import Foundation

enum WellnessScoreCalculator {
    /// Computes a 0–100 wellness score from a single check-in.
    static func compute(stress: Int, urge: SpendingUrge, sleep: Int?) -> Int {
        var score = 50

        // Stress: 1=best (+20), 10=worst (-20)
        let stressDelta = Int((Double(5 - stress) / 4.5) * 20)
        score += stressDelta

        // Spending urge
        switch urge {
        case .none:   score += 15
        case .mild:   score += 0
        case .strong: score -= 15
        }

        // Sleep quality 1-5
        if let sleep {
            let sleepDelta = Int((Double(sleep - 3) / 2.0) * 10)
            score += sleepDelta
        }

        return max(0, min(100, score))
    }
}
