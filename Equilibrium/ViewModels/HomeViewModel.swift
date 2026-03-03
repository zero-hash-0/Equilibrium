import SwiftUI
import SwiftData

@MainActor
@Observable
final class HomeViewModel {
    // Computed helpers — drive UI from @Query data passed in by the view
    func todayCheckIn(from checkIns: [CheckIn]) -> CheckIn? {
        checkIns.first { $0.dayKey == DateHelpers.todayKey() }
    }

    func latestInsight(from checkIns: [CheckIn]) -> AIInsight? {
        checkIns
            .sorted { $0.createdAt > $1.createdAt }
            .first?.insight
    }

    func wellnessScore(from checkIns: [CheckIn]) -> Int? {
        todayCheckIn(from: checkIns)?.wellnessScore
            ?? checkIns.sorted { $0.createdAt > $1.createdAt }.first?.wellnessScore
    }
}
