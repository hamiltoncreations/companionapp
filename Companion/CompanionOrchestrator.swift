import Foundation

/// Memory protocol
protocol Memory {
    var name: String { get }
    func initialize() async
}

/// Simple memory manager
class MemoryManager {
    private var memories: [any Memory] = []
    
    func addMemory(_ memory: any Memory) {
        memories.append(memory)
        print("MemoryManager: Added \(memory.name)")
    }
    
    func initialize() async {
        print("MemoryManager: Initializing all memories...")
        for memory in memories {
            await memory.initialize()
        }
        print("MemoryManager: All memories initialized.")
    }
}

/// Simple tool manager
class ToolManager {
    private var tools: [any Tool] = []
    
    func addTool(_ tool: any Tool) {
        tools.append(tool)
        print("ToolManager: Added \(tool.name) tool.")
    }
    
    func decideAndExecuteTool(for input: String) async -> String? {
        print("ToolManager: Deciding if a tool is needed for input: '\(input)'")
        // Simple keyword-based decision for now
        if input.lowercased().contains("calendar") || input.lowercased().contains("schedule") {
            return await tools.first(where: { $0.name == "Calendar" })?.execute(input: input)
        } else if input.lowercased().contains("weather") {
            return await tools.first(where: { $0.name == "Weather" })?.execute(input: input)
        } else if input.lowercased().contains("remind") {
            return await tools.first(where: { $0.name == "Reminder" })?.execute(input: input)
        } else if input.lowercased().contains("music") || input.lowercased().contains("play song") {
            return await tools.first(where: { $0.name == "Music" })?.execute(input: input)
        } else if input.lowercased().contains("photo") || input.lowercased().contains("picture") {
            return await tools.first(where: { $0.name == "Photo" })?.execute(input: input)
        }
        print("ToolManager: No tool selected.")
        return nil
    }
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
    
    // Memory systems
    private var shortTermMemory: ShortTermMemory
    private var longTermMemory: LongTermMemory
    private var episodicMemory: EpisodicMemory
    private var emotionalMemory: EmotionalMemory
    
    init() {
        self.aiManager = AIManager()
        self.memoryManager = MemoryManager()
        self.toolManager = ToolManager()
        
        self.shortTermMemory = ShortTermMemory()
        self.longTermMemory = LongTermMemory()
        self.episodicMemory = EpisodicMemory()
        self.emotionalMemory = EmotionalMemory()
        
        setupMemorySystems()
        setupTools()
    }
    
    func load() async throws {
        print("🚀 Loading CompanionOrchestrator...")
        
        // Load AI manager (don't throw if it fails, just use fallback)
        do {
            try await aiManager.load()
        } catch {
            print("⚠️ AI manager failed to load, using fallback: \(error)")
        }
        
        // Initialize memory systems
        await memoryManager.initialize()
        
        isReady = true
        print("✅ CompanionOrchestrator loaded successfully")
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
        let longTermContext = await longTermMemory.retrieveContext(for: input)
        
        // 3. Get current emotional state
        let emotionalState = await emotionalMemory.getCurrentEmotionalState()
        
        // 4. Use just the user input for now (simplified)
        let fullContext = input
        
        // 5. Decide if a tool is needed (simplified for now)
        if let toolResponse = await toolManager.decideAndExecuteTool(for: input) {
            await shortTermMemory.addMessage(toolResponse)
            await updateMemories(input: input, response: toolResponse, emotionalState: emotionalState)
            return toolResponse
        }
        
        // 6. Generate response using the selected AI provider
        let aiResponse = await aiManager.generateResponse(to: fullContext)
        
        // Update current AI provider for debugging
        currentAIProvider = aiManager.currentProvider.name
        
        // 7. Update memory systems with the AI's response
        await shortTermMemory.addMessage(aiResponse)
        await updateMemories(input: input, response: aiResponse, emotionalState: emotionalState)
        
        print("✅ Orchestrator generated response: '\(aiResponse)'")
        return aiResponse
    }
    
    private func setupMemorySystems() {
        memoryManager.addMemory(shortTermMemory)
        memoryManager.addMemory(longTermMemory)
        memoryManager.addMemory(episodicMemory)
        memoryManager.addMemory(emotionalMemory)
    }
    
    private func setupTools() {
        // Calendar tool
        toolManager.addTool(CalendarTool())
        
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