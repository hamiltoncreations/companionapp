import Foundation

/// Memory protocol
protocol Memory {
    var name: String { get }
    func initialize() async
}



/// Advanced companion orchestrator
/// Manages memory, tools, and multiple AI systems
class CompanionOrchestrator: ObservableObject {
    @Published var isReady: Bool = false
    @Published var currentMemory: String = ""
    @Published var currentAIProvider: String = "Unknown"
    
    private var aiManager: AIManager
    private var memoryManager: MemoryManager
    private var toolManager: ToolManager
    private var personalityEngine: PersonalityEngine
    
    // Memory systems
    private var shortTermMemory: ShortTermMemory
    private var longTermMemory: LongTermMemory
    private var episodicMemory: EpisodicMemory
    private var emotionalMemory: EmotionalMemory
    
    init() {
        self.aiManager = AIManager()
        self.memoryManager = MemoryManager()
        self.toolManager = ToolManager()
        self.personalityEngine = PersonalityEngine()
        
        self.shortTermMemory = ShortTermMemory()
        self.longTermMemory = LongTermMemory()
        self.episodicMemory = EpisodicMemory()
        self.emotionalMemory = EmotionalMemory()
        
        setupMemorySystems()
        setupTools()
        
        // Make orchestrator ready immediately with fallback AI
        isReady = true
        currentAIProvider = aiManager.currentProvider.name
        print("✅ CompanionOrchestrator ready with fallback AI: \(currentAIProvider)")
    }
    
    func load() async throws {
        print("🚀 Upgrading CompanionOrchestrator with better AI...")
        print("🔍 Current AI provider before upgrade: \(currentAIProvider)")
        
        // Try to upgrade to better AI providers
        do {
            print("🔄 Calling aiManager.load()...")
            try await aiManager.load()
            currentAIProvider = aiManager.currentProvider.name
            print("✅ Upgraded to better AI: \(currentAIProvider)")
        } catch {
            print("⚠️ AI upgrade failed, keeping fallback: \(error)")
        }
        
        // Initialize memory systems
        print("🧠 Initializing memory systems...")
        await memoryManager.initialize()
        
        print("✅ CompanionOrchestrator upgrade complete")
        print("🔍 Final AI provider: \(currentAIProvider)")
    }
    
    func generateResponse(to input: String) async -> String {
        guard isReady else {
            print("❌ Orchestrator not ready, falling back to basic response.")
            return "I'm still waking up. Please give me a moment."
        }
        
        print("🧠 Orchestrating response for: '\(input)'")
        
        // 1. Update memory systems with new input
        await shortTermMemory.addMessage(input)
        
        // 2. Retrieve relevant context from long-term memory
        let _ = await longTermMemory.retrieveContext(for: input)
        
        // 3. Get current emotional state
        let emotionalState = await emotionalMemory.getCurrentEmotionalState()
        
        // 4. Decide if a tool is needed (simplified for now)
        if let toolResponse = await toolManager.decideAndExecuteTool(for: input) {
            await shortTermMemory.addMessage(toolResponse)
            await updateMemories(input: input, response: toolResponse, emotionalState: emotionalState)
            return toolResponse
        }
        
        // 5. Generate response using the selected AI provider
        let aiResponse = await aiManager.generateResponse(to: input)
        
        // Update current AI provider for debugging
        currentAIProvider = aiManager.currentProvider.name
        
        // 6. Apply light personality enhancements to the AI response
        let enhancedResponse = personalityEngine.enhanceAIResponse(aiResponse, for: input)
        
        // 7. Update memory systems with the enhanced response
        await shortTermMemory.addMessage(enhancedResponse)
        await updateMemories(input: input, response: enhancedResponse, emotionalState: emotionalState)
        
        print("✅ Orchestrator generated response: '\(enhancedResponse)'")
        return enhancedResponse
    }
    
    private func setupMemorySystems() {
        memoryManager.addMemory(shortTermMemory)
        memoryManager.addMemory(longTermMemory)
        memoryManager.addMemory(episodicMemory)
        memoryManager.addMemory(emotionalMemory)
    }
    
    private func setupTools() {
        // Calendar tool
        if #available(macOS 14.0, iOS 17.0, *) {
            toolManager.addTool(CalendarTool())
        }
        
        // Weather tool
        toolManager.addTool(WeatherTool())
        
        // Reminder tool
        toolManager.addTool(ReminderTool())
        
        // Music tool
        toolManager.addTool(MusicTool())
        
        // Photo tool
        toolManager.addTool(PhotoTool())
    }
    
    /// Update all memory systems with the interaction
    private func updateMemories(input: String, response: String, emotionalState: EmotionalState) async {
        // Update episodic memory with the conversation
        await episodicMemory.addConversation(
            input: input,
            response: response,
            timestamp: Date()
        )
        
        // Update long-term memory based on significance (simplified)
        if input.lowercased().contains("favorite") || input.lowercased().contains("important") {
            await longTermMemory.addFact("User mentioned something important: \(input)")
        }
        
        // Update emotional memory based on sentiment (simplified)
        if input.lowercased().contains("happy") || response.lowercased().contains("great") {
            await emotionalMemory.updateEmotionalState(to: .joy)
        } else if input.lowercased().contains("sad") || response.lowercased().contains("sorry") {
            await emotionalMemory.updateEmotionalState(to: .sadness)
        }
    }
}