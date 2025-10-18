import Foundation

/// Protocol defining the interface for all AI providers
/// This allows seamless swapping between local and cloud AI solutions
protocol AIProvider {
    /// Whether the AI provider is ready to generate responses
    var isReady: Bool { get }
    
    /// Generate a response to the given input
    /// - Parameter input: The user's input text
    /// - Returns: The AI's response
    func generateResponse(to input: String) async -> String
    
    /// Load/initialize the AI provider
    func load() async throws
    
    /// Get the name of the AI provider
    var name: String { get }
    
    /// Get the model size information (for local models)
    var modelSize: String? { get }
}

/// Configuration for AI providers
struct AIConfiguration {
    let maxTokens: Int
    let temperature: Double
    let systemPrompt: String?
    
    static let `default` = AIConfiguration(
        maxTokens: 100,
        temperature: 0.7,
        systemPrompt: nil
    )
}
