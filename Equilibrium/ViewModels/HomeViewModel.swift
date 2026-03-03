import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    var todayCheckIn: CheckIn? = nil
    var latestInsight: AIInsight? = nil
    var wellnessScore: Int = 50

    func refresh(checkIns: [CheckIn]) {
        todayCheckIn   = checkIns.first(where: { $0.date.isToday })
        latestInsight  = checkIns
            .sorted { $0.createdAt > $1.createdAt }
            .first?.insight
        wellnessScore  = todayCheckIn?.wellnessScore
            ?? checkIns.sorted { $0.createdAt > $1.createdAt }.first?.wellnessScore
            ?? 50
    }
}
