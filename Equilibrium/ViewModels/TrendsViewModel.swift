import SwiftUI

enum TrendRange: String, CaseIterable {
    case sevenDays  = "7 Days"
    case thirtyDays = "30 Days"

    var days: Int { self == .sevenDays ? 7 : 30 }
}

struct TrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

@Observable
final class TrendsViewModel {
    var selectedRange: TrendRange = .sevenDays

    func stressTrend(from checkIns: [CheckIn]) -> [TrendPoint] {
        filtered(checkIns).map { TrendPoint(date: $0.date, value: Double($0.stressLevel)) }
    }

    func wellnessTrend(from checkIns: [CheckIn]) -> [TrendPoint] {
        filtered(checkIns).map { TrendPoint(date: $0.date, value: Double($0.wellnessScore)) }
    }

    func urgeFrequency(from checkIns: [CheckIn]) -> [TrendPoint] {
        filtered(checkIns).map { ci -> TrendPoint in
            let val: Double
            switch ci.spendingUrgeEnum {
            case .none:   val = 0
            case .mild:   val = 1
            case .strong: val = 2
            }
            return TrendPoint(date: ci.date, value: val)
        }
    }

    private func filtered(_ checkIns: [CheckIn]) -> [CheckIn] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -selectedRange.days, to: Date())!
        return checkIns
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }
    }
}
