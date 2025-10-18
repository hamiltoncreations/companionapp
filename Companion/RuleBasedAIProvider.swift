import Foundation

/// Rule-based AI provider that uses the original CompanionAI logic
class RuleBasedAIProvider: AIProvider {
    var name: String = "Rule-Based AI"
    var isReady: Bool = true
    var modelSize: String? = nil
    
    private let companionAI: CompanionAI
    
    init() {
        self.companionAI = CompanionAI()
    }
    
    func load() async throws {
        // Rule-based AI is always ready
        isReady = true
        print("✅ Rule-based AI loaded")
    }
    
    func generateResponse(to input: String) async -> String {
        return companionAI.generateResponse(to: input)
    }
}
