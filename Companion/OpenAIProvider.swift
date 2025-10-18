import Foundation

/// OpenAI/ChatGPT Provider for cloud-based AI
class OpenAIProvider: CloudAIProvider {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
        super.init(name: "OpenAI ChatGPT")
    }
    
    override func load() async throws {
        print("🚀 Loading OpenAI ChatGPT...")
        // No model loading needed for cloud API
        print("✅ OpenAI ChatGPT ready")
    }
    
    override func generateResponse(to input: String) async -> String {
        print("🤖 OpenAI ChatGPT generating response for: '\(input)'")
        
        do {
            let response = try await callOpenAIAPI(prompt: input)
            print("✅ OpenAI ChatGPT response: '\(response)'")
            return response
        } catch {
            print("❌ OpenAI ChatGPT error: \(error)")
            return "I'm sorry, I'm having trouble connecting right now. Please try again later."
        }
    }
    
    private func callOpenAIAPI(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a friendly AI companion. Respond naturally and conversationally. Keep responses brief and engaging. Don't mention technical details or context."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 100,
            "temperature": 0.8
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "Invalid response format", code: -1)
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
