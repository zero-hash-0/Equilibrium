import Foundation

enum AIServiceError: LocalizedError {
    case missingAPIKey
    case networkError(Error)
    case badResponse(Int)
    case parseError(String)
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:          return "API key not configured. See README for .xcconfig setup."
        case .networkError(let e):    return "Network error: \(e.localizedDescription)"
        case .badResponse(let code):  return "Server returned status \(code)."
        case .parseError(let msg):    return "Couldn't parse AI response: \(msg)"
        case .rateLimitExceeded:      return "You've used 3 regenerations today. Try again tomorrow."
        }
    }
}

// MARK: - Rate-limit store (simple UserDefaults)
private enum RegenerateLimit {
    static let key = "ai_regen_date"
    static let countKey = "ai_regen_count"
    static let maxPerDay = 3

    static func canRegenerate() -> Bool {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        if let stored = defaults.object(forKey: key) as? Date,
           Calendar.current.isDate(stored, inSameDayAs: today) {
            return defaults.integer(forKey: countKey) < maxPerDay
        }
        // New day — reset
        defaults.set(today, forKey: key)
        defaults.set(0, forKey: countKey)
        return true
    }

    static func recordRegeneration() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: countKey)
        defaults.set(count + 1, forKey: countKey)
    }
}

// MARK: - Request / Response shapes
private struct ChatRequest: Encodable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let response_format: ResponseFormat

    struct Message: Encodable {
        let role: String
        let content: String
    }
    struct ResponseFormat: Encodable {
        let type: String
    }
}

private struct ChatResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable { let content: String }
        let message: Message
    }
    let choices: [Choice]
}

private struct InsightPayload: Decodable {
    let insight: String
    let action: String
    let if_then: String
}

// MARK: - AIService
actor AIService {
    static let shared = AIService()
    private init() {}

    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "AI_API_KEY") as? String ?? ""
    }

    private var baseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "AI_BASE_URL") as? String
            ?? "https://api.openai.com/v1"
    }

    private var model: String {
        Bundle.main.object(forInfoDictionaryKey: "AI_MODEL") as? String
            ?? "gpt-4o-mini"
    }

    func generateInsight(profile: UserProfile, checkIn: CheckIn) async throws -> AIInsightDTO {
        guard !apiKey.isEmpty else { throw AIServiceError.missingAPIKey }

        let prompt = buildPrompt(profile: profile, checkIn: checkIn)
        let request = try buildURLRequest(prompt: prompt)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIServiceError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw AIServiceError.parseError("Non-HTTP response")
        }
        guard (200...299).contains(http.statusCode) else {
            throw AIServiceError.badResponse(http.statusCode)
        }

        let chat = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chat.choices.first?.message.content else {
            throw AIServiceError.parseError("Empty choices array")
        }

        guard let jsonData = content.data(using: .utf8),
              let payload = try? JSONDecoder().decode(InsightPayload.self, from: jsonData) else {
            throw AIServiceError.parseError("Response was not valid JSON: \(content.prefix(200))")
        }

        return AIInsightDTO(
            insight: payload.insight,
            action: payload.action,
            ifThen: payload.if_then,
            raw: content
        )
    }

    func generateInsightWithRateLimit(profile: UserProfile, checkIn: CheckIn) async throws -> AIInsightDTO {
        guard RegenerateLimit.canRegenerate() else {
            throw AIServiceError.rateLimitExceeded
        }
        let dto = try await generateInsight(profile: profile, checkIn: checkIn)
        RegenerateLimit.recordRegeneration()
        return dto
    }

    // MARK: Private helpers

    private func buildPrompt(profile: UserProfile, checkIn: CheckIn) -> String {
        """
        You are a compassionate financial wellness coach. Respond ONLY with valid JSON — no prose, no markdown.

        User profile:
        - Name: \(profile.name)
        - Primary goal: \(profile.primaryGoal)
        - Baseline stress: \(profile.baselineStress)/10

        Today's check-in:
        - Stress level: \(checkIn.stressLevel)/10
        - Spending urges: \(checkIn.spendingUrge)
        - Sleep quality: \(checkIn.sleepQuality.map { "\($0)/5" } ?? "not provided")
        - Goal today: \(checkIn.goalToday)
        \(checkIn.note.map { "- Note: \($0)" } ?? "")

        Respond ONLY with this JSON schema (no other text):
        {
          "insight": "<1-2 sentence observation about their financial wellness state>",
          "action": "<single concrete small action they can take today>",
          "if_then": "<one if-then implementation intention, e.g. If I feel the urge to spend, I will...>"
        }
        """
    }

    private func buildURLRequest(prompt: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw AIServiceError.parseError("Invalid base URL")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: "You respond only with valid JSON. No markdown, no extra text."),
                .init(role: "user", content: prompt)
            ],
            temperature: 0.7,
            response_format: .init(type: "json_object")
        )
        req.httpBody = try JSONEncoder().encode(body)
        return req
    }
}
