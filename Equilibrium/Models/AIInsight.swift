import Foundation
import SwiftData

@Model
final class AIInsight {
    var id: UUID
    var checkInId: UUID
    var insightText: String
    var actionText: String
    var ifThenText: String
    var rawResponse: String
    var createdAt: Date

    init(checkInId: UUID, insightText: String, actionText: String, ifThenText: String, rawResponse: String) {
        self.id          = UUID()
        self.checkInId   = checkInId
        self.insightText = insightText
        self.actionText  = actionText
        self.ifThenText  = ifThenText
        self.rawResponse = rawResponse
        self.createdAt   = Date()
    }
}

// DTO returned from AIService before persisting
struct AIInsightDTO {
    let insight: String
    let action: String
    let ifThen: String
    let raw: String
}
