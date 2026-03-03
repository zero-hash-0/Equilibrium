import Foundation
import SwiftData

@Model
final class AIInsight {
    @Attribute(.unique) var id: UUID
    var insightText: String
    var actionText: String
    var ifThenText: String
    var rawResponse: String
    var createdAt: Date

    @Relationship var checkIn: CheckIn?

    init(insightText: String, actionText: String, ifThenText: String, rawResponse: String) {
        self.id          = UUID()
        self.insightText = insightText
        self.actionText  = actionText
        self.ifThenText  = ifThenText
        self.rawResponse = rawResponse
        self.createdAt   = Date()
    }
}

struct AIInsightDTO: Decodable, Sendable {
    let insight: String
    let action: String
    let if_then: String
}
