import Foundation

/// Base class for cloud AI providers (APIs)
class CloudAIProvider: AIProvider {
    var isReady: Bool = false
    let name: String
    let modelSize: String? = nil // Cloud models don't have local size
    
    init(name: String) {
        self.name = name
    }
    
    func generateResponse(to input: String) async -> String {
        // Override in subclasses
        return "Cloud AI response not implemented"
    }
    
    func load() async throws {
        // Override in subclasses
        isReady = true
    }
}

// OpenAIProvider is now in its own file: OpenAIProvider.swift

/// Anthropic Claude API provider
class AnthropicProvider: CloudAIProvider {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "claude-3-haiku-20240307") {
        self.apiKey = apiKey
        self.model = model
        super.init(name: "Anthropic \(model)")
    }
    
    override func generateResponse(to input: String) async -> String {
        // TODO: Implement Anthropic API call
        return "Claude response: \(input)"
    }
}
