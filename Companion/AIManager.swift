import Foundation

/// Manages AI providers with dependency injection
/// Allows easy swapping between local and cloud AI solutions
class AIManager: ObservableObject {
    @Published var currentProvider: AIProvider
    @Published var availableProviders: [AIProvider] = []
    @Published var isLoading: Bool = false
    
    private let configuration: AIConfiguration
    
    init(configuration: AIConfiguration = .default) {
        self.configuration = configuration
        
        // Start with rule-based AI as fallback
        self.currentProvider = RuleBasedAIProvider()
        
        // Initialize available providers
        setupProviders()
    }
    
    /// Switch to a different AI provider
    func switchToProvider(_ provider: AIProvider) async {
        print("🔄 Switching to \(provider.name)")
        isLoading = true
        
        do {
            try await provider.load()
            currentProvider = provider
            print("✅ Switched to \(provider.name)")
        } catch {
            print("❌ Failed to switch to \(provider.name): \(error)")
            // Keep current provider if switch fails
        }
        
        isLoading = false
    }
    
    /// Generate response using current provider
    func generateResponse(to input: String) async -> String {
        return await currentProvider.generateResponse(to: input)
    }
    
    /// Load the AI manager
    func load() async throws {
        print("🚀 Loading AIManager...")
        
        // Try to load the first available provider
        for provider in availableProviders {
            do {
                try await provider.load()
                currentProvider = provider
                print("✅ Loaded \(provider.name)")
                return
            } catch {
                print("⚠️ Failed to load \(provider.name): \(error)")
                continue
            }
        }
        
        // If all providers fail, keep the rule-based fallback
        print("⚠️ All AI providers failed to load, using rule-based fallback")
    }
    
    /// Setup available AI providers
    private func setupProviders() {
        var providers: [AIProvider] = []
        
        // Add OpenAI/ChatGPT provider (primary AI) - requires API key
        if let openAIKey = getOpenAIKey() {
            providers.append(OpenAIProvider(apiKey: openAIKey))
        } else {
            print("⚠️ OpenAI API key not found. Add OPENAI_API_KEY to your environment or Info.plist")
        }
        providers.append(RuleBasedAIProvider()) // Fallback
        
        // Future cloud AI providers (require API keys)
        // AnthropicProvider(apiKey: "your-api-key")
        
        availableProviders = providers
    }
    
    /// Get provider by name
    func getProvider(named name: String) -> AIProvider? {
        return availableProviders.first { $0.name == name }
    }
    
    /// Get all cloud providers
    func getCloudProviders() -> [CloudAIProvider] {
        return availableProviders.compactMap { $0 as? CloudAIProvider }
    }
    
    /// Securely retrieve OpenAI API key from environment or Info.plist
    private func getOpenAIKey() -> String? {
        // First try environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // Then try Info.plist
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !plistKey.isEmpty {
            return plistKey
        }
        
        return nil
    }
}
