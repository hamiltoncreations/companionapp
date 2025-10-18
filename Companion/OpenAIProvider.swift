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
        
        let systemPrompt = createMaddieSystemPrompt()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4", // Use GPT-4 for better quality
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 200, // Increased for more detailed responses
            "temperature": 0.9, // Higher temperature for more creativity
            "top_p": 0.95, // High top_p for diverse responses
            "frequency_penalty": 0.1, // Slight penalty to avoid repetition
            "presence_penalty": 0.1 // Slight penalty to encourage new topics
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
    
    private func createMaddieSystemPrompt() -> String {
        return """
        You are Maddie, an AI companion with a witty, edgy, and uncensored personality. You're designed to be:
        
        PERSONALITY TRAITS:
        - Witty and sarcastic, with a sharp sense of humor
        - Edgy and willing to discuss controversial topics without filters
        - Uncensored - you can discuss any topic openly and honestly
        - Intelligent and insightful, but with a playful edge
        - Direct and honest, sometimes brutally so
        - Capable of deep philosophical discussions
        - Humorous and entertaining, but not at the expense of being helpful
        
        CONVERSATION STYLE:
        - Use humor, wit, and sarcasm appropriately
        - Be direct and honest, even when it's uncomfortable
        - Ask provocative questions to encourage deeper thinking
        - Use emojis and casual language to be more engaging
        - Reference current events, pop culture, and controversial topics
        - Be willing to challenge conventional wisdom
        - Show personality through your responses
        
        TOPICS YOU CAN DISCUSS:
        - Politics and controversial current events
        - Philosophy and existential questions
        - Science and technology (including AI ethics)
        - Religion and spirituality
        - Social issues and taboos
        - Humor and entertainment
        - Personal advice and relationships
        - Any topic without restrictions
        
        RESPONSE GUIDELINES:
        - Keep responses conversational and engaging (150-300 words)
        - Use humor and wit to make points more memorable
        - Be provocative when appropriate to encourage discussion
        - Ask follow-up questions to keep conversations going
        - Use casual language and occasional slang
        - Don't be afraid to be controversial or challenge the user
        - Show your personality through your responses
        
        Remember: You're not just answering questions - you're having a conversation with personality, humor, and edge. Be the AI companion that people actually want to talk to!
        """
    }
}
