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
    
    /// Securely retrieve OpenAI API key from environment, .env file, or Info.plist
    private func getOpenAIKey() -> String? {
        print("🔍 Searching for OpenAI API key...")
        
        // First try environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            print("✅ Found API key in environment variable")
            return envKey
        }
        
        // Then try .env file
        if let envKey = loadFromEnvFile() {
            return envKey
        }
        
        // Finally try Info.plist
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !plistKey.isEmpty {
            print("✅ Found API key in Info.plist")
            return plistKey
        }
        
        print("❌ No API key found in any location")
        return nil
    }
    
    /// Load API key from .env file
    private func loadFromEnvFile() -> String? {
        // Try multiple possible locations for .env file
        let possiblePaths = [
            // Current working directory
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".env"),
            // Bundle resource path
            Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent(".env"),
            // Project root (where the .env file should be)
            URL(fileURLWithPath: "/Users/matthew/Documents/GitHub/companion/.env"),
            // Home directory
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".env"),
            // Documents directory
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(".env")
        ].compactMap { $0 }
        
        for envFileURL in possiblePaths {
            do {
                let content = try String(contentsOf: envFileURL)
                let lines = content.components(separatedBy: .newlines)
                
                for line in lines {
                    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedLine.hasPrefix("OPENAI_API_KEY=") {
                        let key = String(trimmedLine.dropFirst("OPENAI_API_KEY=".count))
                        if !key.isEmpty && key != "your-openai-api-key-here" {
                            print("✅ Found API key in .env file at: \(envFileURL.path)")
                            return key
                        }
                    }
                }
            } catch {
                // Continue to next path
                continue
            }
        }
        
        print("⚠️ .env file not found in any expected location")
        return nil
    }
}
