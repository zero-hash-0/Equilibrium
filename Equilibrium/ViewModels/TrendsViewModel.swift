import SwiftUI

@MainActor
@Observable
final class TrendsViewModel {
    var rangeDays: Int = 7

    struct TrendPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let label: String
    }

    func filtered(_ checkIns: [CheckIn]) -> [CheckIn] {
        let cutoff = DateHelpers.startOfDay(daysAgo: rangeDays)
        return checkIns
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }
    }

    func stressSeries(from checkIns: [CheckIn]) -> [TrendPoint] {
        filtered(checkIns).map {
            TrendPoint(date: $0.date, value: Double($0.stressLevel), label: $0.dayKey)
        }
    }

    func wellnessSeries(from checkIns: [CheckIn]) -> [TrendPoint] {
        filtered(checkIns).map {
            TrendPoint(date: $0.date, value: Double($0.wellnessScore), label: $0.dayKey)
        }
    }

    func urgeSeries(from checkIns: [CheckIn]) -> [TrendPoint] {
        filtered(checkIns).map { ci in
            let val: Double
            switch ci.spendingUrge {
            case .none:   val = 0
            case .mild:   val = 1
            case .strong: val = 2
            }
            return TrendPoint(date: ci.date, value: val, label: ci.dayKey)
        }
    }
}
