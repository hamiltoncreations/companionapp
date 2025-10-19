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
        print("📋 Available providers to try: \(availableProviders.map { $0.name })")
        
        // Try to load the first available provider
        for provider in availableProviders {
            print("🔄 Trying to load provider: \(provider.name)")
            do {
                try await provider.load()
                currentProvider = provider
                print("✅ Successfully loaded \(provider.name)")
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
        print("🚀 Setting up AI providers...")
        var providers: [AIProvider] = []
        
        // Add OpenAI/ChatGPT provider (primary AI) - requires API key
        if let openAIKey = getOpenAIKey() {
            print("✅ OpenAI API key found, adding OpenAI provider")
            providers.append(OpenAIProvider(apiKey: openAIKey))
        } else {
            print("⚠️ OpenAI API key not found. Add OPENAI_API_KEY to your environment or Info.plist")
        }
        
        print("✅ Adding rule-based fallback provider")
        providers.append(RuleBasedAIProvider()) // Fallback
        
        // Future cloud AI providers (require API keys)
        // AnthropicProvider(apiKey: "your-api-key")
        
        availableProviders = providers
        print("📋 Available providers: \(providers.map { $0.name })")
    }
    
    /// Get provider by name
    func getProvider(named name: String) -> AIProvider? {
        return availableProviders.first { $0.name == name }
    }
    
    /// Get all cloud providers
    func getCloudProviders() -> [CloudAIProvider] {
        return availableProviders.compactMap { $0 as? CloudAIProvider }
    }
    
    /// Securely retrieve OpenAI API key from .env file only
    private func getOpenAIKey() -> String? {
        print("🔍 Searching for OpenAI API key in .env file...")
        
        // Only use .env file for security
        if let envKey = loadFromEnvFile() {
            return envKey
        }
        
        print("❌ No API key found in .env file")
        return nil
    }
    
    /// Load API key from .env file
    private func loadFromEnvFile() -> String? {
        print("🔍 Searching for .env file...")
        
        // Try multiple possible locations for .env file
        let possiblePaths = [
            // Current working directory
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(".env"),
            // Bundle resource path
            Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent(".env"),
            // Project root (where the .env file should be)
            URL(fileURLWithPath: "/Users/matthew/Documents/GitHub/companion/.env"),
            // Documents directory
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(".env")
        ].compactMap { $0 }
        
        print("🔍 Checking paths:")
        for path in possiblePaths {
            print("  - \(path.path)")
        }
        
        for envFileURL in possiblePaths {
            do {
                print("🔍 Trying to read: \(envFileURL.path)")
                let content = try String(contentsOf: envFileURL)
                print("✅ Successfully read .env file at: \(envFileURL.path)")
                print("📄 File content length: \(content.count) characters")
                
                let lines = content.components(separatedBy: .newlines)
                
                for line in lines {
                    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedLine.hasPrefix("OPENAI_API_KEY=") {
                        let key = String(trimmedLine.dropFirst("OPENAI_API_KEY=".count))
                        print("🔑 Found API key, length: \(key.count) characters")
                        print("🔑 Key starts with: \(String(key.prefix(10)))...")
                        
                        if !key.isEmpty && key != "your-openai-api-key-here" {
                            print("✅ Valid API key found in .env file at: \(envFileURL.path)")
                            return key
                        } else {
                            print("❌ API key is empty or placeholder")
                        }
                    }
                }
            } catch {
                print("❌ Failed to read .env file at \(envFileURL.path): \(error)")
                continue
            }
        }
        
        print("⚠️ .env file not found in any expected location")
        return nil
    }
}
