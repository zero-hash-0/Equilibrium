import SwiftUI
import SwiftData

@Observable
final class CoachViewModel {
    enum State {
        case loading
        case success(AIInsight)
        case error(String)
    }

    var state: State = .loading
    var isRegenerating = false

    func loadInsight(checkIn: CheckIn, profile: UserProfile, context: ModelContext) async {
        // If already has insight, just display it
        if let existing = checkIn.insight {
            state = .success(existing)
            return
        }
        await fetch(checkIn: checkIn, profile: profile, context: context, isRegen: false)
    }

    func regenerate(checkIn: CheckIn, profile: UserProfile, context: ModelContext) async {
        isRegenerating = true
        defer { isRegenerating = false }
        await fetch(checkIn: checkIn, profile: profile, context: context, isRegen: true)
    }

    private func fetch(checkIn: CheckIn, profile: UserProfile, context: ModelContext, isRegen: Bool) async {
        state = .loading
        do {
            let dto = isRegen
                ? try await AIService.shared.generateInsightWithRateLimit(profile: profile, checkIn: checkIn)
                : try await AIService.shared.generateInsight(profile: profile, checkIn: checkIn)

            // Remove old insight if regenerating
            if let old = checkIn.insight {
                context.delete(old)
            }

            let insight = AIInsight(
                checkInId:   checkIn.id,
                insightText: dto.insight,
                actionText:  dto.action,
                ifThenText:  dto.ifThen,
                rawResponse: dto.raw
            )
            context.insert(insight)
            checkIn.insight = insight
            try? context.save()
            state = .success(insight)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
