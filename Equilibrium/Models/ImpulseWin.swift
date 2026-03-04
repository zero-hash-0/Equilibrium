import Foundation
import SwiftData

@Model
final class ImpulseWin {
    @Attribute(.unique) var id: UUID
    var triggerRaw: String       // ImpulseTrigger.rawValue
    var urgeStrength: Int        // 1-10
    var estimatedSavings: Double // 0 if user skipped
    var dayKey: String
    var createdAt: Date

    init(trigger: String, urgeStrength: Int, estimatedSavings: Double) {
        self.id               = UUID()
        self.triggerRaw       = trigger
        self.urgeStrength     = urgeStrength
        self.estimatedSavings = estimatedSavings
        self.dayKey           = DateHelpers.todayKey()
        self.createdAt        = Date()
    }
}
