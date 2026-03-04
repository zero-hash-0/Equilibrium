import Foundation

// MARK: - Sendable snapshots (cross-actor safe)
struct ProfileSnapshot: Sendable {
    let name: String
    let primaryGoal: String
    let baselineStress: Int
}

struct CheckInSnapshot: Sendable {
    let stressLevel: Int
    let spendingUrge: String
    let sleepQuality: Int?
    let goalToday: String
    let note: String?
}

// MARK: - Errors
enum AIServiceError: LocalizedError {
    case missingAPIKey
    case networkError(Error)
    case httpError(Int)
    case emptyResponse
    case parseError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key configured. Open Config/Debug.xcconfig and add your OPENAI_API_KEY."
        case .networkError(let e):
            return "Network error: \(e.localizedDescription)"
        case .httpError(let code):
            return "Server returned \(code). Check your API key and quota."
        case .emptyResponse:
            return "The AI returned an empty response. Please retry."
        case .parseError(let detail):
            return "Could not parse AI response: \(detail)"
        }
    }
}

// MARK: - OpenAI request shapes
private struct ChatRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }
    struct ResponseFormat: Encodable {
        let type: String
    }
    let model: String
    let messages: [Message]
    let temperature: Double
    let response_format: ResponseFormat
}

private struct ChatResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable { let content: String }
        let message: Message
    }
    let choices: [Choice]
}

// MARK: - AIService actor
actor AIService {
    static let shared = AIService()
    private init() {}

    func generateInsight(profile: ProfileSnapshot, checkIn: CheckInSnapshot) async throws -> (dto: AIInsightDTO, raw: String) {
        guard let apiKey = Secrets.openAIKey else { throw AIServiceError.missingAPIKey }

        let prompt = buildPrompt(profile: profile, checkIn: checkIn)
        let request = try buildRequest(apiKey: apiKey, prompt: prompt)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AIServiceError.networkError(error)
        }

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw AIServiceError.httpError(http.statusCode)
        }

        let chat = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = chat.choices.first?.message.content, !content.isEmpty else {
            throw AIServiceError.emptyResponse
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let jsonData = trimmed.data(using: .utf8),
              let dto = try? JSONDecoder().decode(AIInsightDTO.self, from: jsonData) else {
            throw AIServiceError.parseError(String(trimmed.prefix(200)))
        }

        return (dto, trimmed)
    }

    // MARK: Private helpers

    private func buildPrompt(profile: ProfileSnapshot, checkIn: CheckInSnapshot) -> String {
        let profileJSON = """
        {"name":"\(profile.name)","primaryGoal":"\(profile.primaryGoal)","baselineStress":\(profile.baselineStress)}
        """
        var checkInDict = """
        {"stressLevel":\(checkIn.stressLevel),"spendingUrge":"\(checkIn.spendingUrge)","goalToday":"\(checkIn.goalToday)"
        """
        if let sleep = checkIn.sleepQuality { checkInDict += ",\"sleepQuality\":\(sleep)" }
        if let note = checkIn.note, !note.isEmpty { checkInDict += ",\"note\":\"\(note)\"" }
        checkInDict += "}"

        return """
        You are Equilibrium, a sharp AI Financial Wellness Coach. Output ONLY valid JSON. No markdown. No code fences. No extra keys.
        Return exactly: { "insight": "...", "action": "...", "if_then": "..." }
        Style rules — this is critical:
        - insight: ONE punchy sentence. Max 10 words. Bold truth, no fluff. Like: "Sales create urgency illusions."
        - action: ONE short imperative phrase. Max 8 words. Concrete, right now. Like: "Set a 10-minute timer before checkout."
        - if_then: ONE sentence starting with 'If' containing 'then'. Specific. Like: "If the timer ends and I still want it, then I'll check my savings goal first."
        - No bullet symbols. No em-dashes. No "remember to". Direct voice only.
        - Do not mention being an AI. No medical/legal advice.
        User profile: \(profileJSON)
        Today check-in: \(checkInDict)
        """
    }

    private func buildRequest(apiKey: String, prompt: String) throws -> URLRequest {
        guard let url = URL(string: "\(Secrets.openAIBaseURL)/chat/completions") else {
            throw AIServiceError.parseError("Invalid base URL: \(Secrets.openAIBaseURL)")
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let body = ChatRequest(
            model: Secrets.openAIModel,
            messages: [
                .init(role: "system", content: "You output only valid JSON. No markdown, no code fences, no prose."),
                .init(role: "user", content: prompt)
            ],
            temperature: 0.7,
            response_format: .init(type: "json_object")
        )
        req.httpBody = try JSONEncoder().encode(body)
        return req
    }
}
