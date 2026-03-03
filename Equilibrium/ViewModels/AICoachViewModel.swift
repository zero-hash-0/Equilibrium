import SwiftUI
import SwiftData

@MainActor
@Observable
final class AICoachViewModel {
    enum State: Equatable {
        static func == (lhs: AICoachViewModel.State, rhs: AICoachViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading): return true
            case (.success, .success), (.error, .error): return true
            default: return false
            }
        }
        case idle
        case loading
        case success(AIInsight)
        case error(String)
    }

    var state: State = .idle
    private static let regenKey = "ai_regen"
    private static let maxPerDay = 3

    var remainingRegenerations: Int {
        RateLimiter.remaining(key: Self.regenKey, maxPerDay: Self.maxPerDay)
    }

    var canRegenerate: Bool {
        RateLimiter.canConsume(key: Self.regenKey, maxPerDay: Self.maxPerDay)
    }

    func loadOrGenerate(modelContext: ModelContext, profile: UserProfile, checkIn: CheckIn) async {
        if let existing = checkIn.insight {
            state = .success(existing)
            return
        }
        await generate(modelContext: modelContext, profile: profile, checkIn: checkIn)
    }

    func regenerate(modelContext: ModelContext, profile: UserProfile, checkIn: CheckIn) async {
        guard RateLimiter.consume(key: Self.regenKey, maxPerDay: Self.maxPerDay) else {
            state = .error("Daily regeneration limit reached (3/day). Come back tomorrow.")
            return
        }
        await generate(modelContext: modelContext, profile: profile, checkIn: checkIn)
    }

    private func generate(modelContext: ModelContext, profile: UserProfile, checkIn: CheckIn) async {
        state = .loading

        let profileSnap = ProfileSnapshot(
            name: profile.name,
            primaryGoal: profile.primaryGoalRaw,
            baselineStress: profile.baselineStress
        )
        let checkInSnap = CheckInSnapshot(
            stressLevel: checkIn.stressLevel,
            spendingUrge: checkIn.spendingUrgeRaw,
            sleepQuality: checkIn.sleepQuality,
            goalToday: checkIn.goalTodayRaw,
            note: checkIn.note
        )

        do {
            let (dto, raw) = try await AIService.shared.generateInsight(
                profile: profileSnap,
                checkIn: checkInSnap
            )
            // Remove old insight if regenerating
            if let old = checkIn.insight {
                modelContext.delete(old)
                try? modelContext.save()
            }
            let insight = AIInsight(
                insightText: dto.insight,
                actionText: dto.action,
                ifThenText: dto.if_then,
                rawResponse: raw
            )
            modelContext.insert(insight)
            insight.checkIn = checkIn
            try? modelContext.save()
            state = .success(insight)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
