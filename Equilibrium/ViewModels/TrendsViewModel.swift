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

    func filteredWins(_ wins: [ImpulseWin]) -> [ImpulseWin] {
        let cutoff = DateHelpers.startOfDay(daysAgo: rangeDays)
        return wins.filter { $0.createdAt >= cutoff }.sorted { $0.createdAt < $1.createdAt }
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

    // Impulse wins per day as bar chart data
    func impulseWinSeries(from wins: [ImpulseWin]) -> [TrendPoint] {
        let filtered = filteredWins(wins)
        // Group by dayKey -> count
        var groups: [String: (date: Date, count: Int)] = [:]
        for win in filtered {
            let key = DateHelpers.dayKey(for: win.createdAt)
            if var existing = groups[key] {
                existing.count += 1
                groups[key] = existing
            } else {
                groups[key] = (win.createdAt, 1)
            }
        }
        return groups.values
            .sorted { $0.date < $1.date }
            .map { TrendPoint(date: $0.date, value: Double($0.count), label: DateHelpers.dayKey(for: $0.date)) }
    }

    // Urge frequency: count of check-ins by urge level in range
    struct UrgeFreqPoint: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
        let color: Color
    }

    func urgeFrequency(from checkIns: [CheckIn]) -> [UrgeFreqPoint] {
        let data = filtered(checkIns)
        let noneCount  = data.filter { $0.spendingUrge == .none }.count
        let mildCount  = data.filter { $0.spendingUrge == .mild }.count
        let strongCount = data.filter { $0.spendingUrge == .strong }.count
        return [
            UrgeFreqPoint(label: "None",   count: noneCount,   color: Theme.accentMint),
            UrgeFreqPoint(label: "Mild",   count: mildCount,   color: .yellow),
            UrgeFreqPoint(label: "Strong", count: strongCount, color: .orange),
        ]
    }
}
