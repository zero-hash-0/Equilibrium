import Foundation

enum Secrets {
    static var openAIKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !key.isEmpty,
              key != "your_key_here",
              !key.hasPrefix("$(") else { return nil }
        return key
    }

    static var openAIModel: String {
        (Bundle.main.object(forInfoDictionaryKey: "OPENAI_MODEL") as? String)
            .flatMap { $0.isEmpty ? nil : $0 } ?? "gpt-4.1-mini"
    }

    static var openAIBaseURL: String {
        (Bundle.main.object(forInfoDictionaryKey: "OPENAI_BASE_URL") as? String)
            .flatMap { $0.isEmpty ? nil : $0 } ?? "https://api.openai.com/v1"
    }
}
