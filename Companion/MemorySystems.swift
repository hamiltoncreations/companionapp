import Foundation

/// Protocol for all memory systems
protocol MemorySystem {
    func initialize() async
    func getCurrentState() async -> String
}

/// Short-term memory for current conversation context
class ShortTermMemory: MemorySystem, Memory {
    private var conversationHistory: [ConversationEntry] = []
    private let maxHistoryLength = 10
    
    var name: String { "ShortTermMemory" }
    
    func initialize() async {
        conversationHistory = []
    }
    
    func addMessage(_ message: String) async {
        let entry = ConversationEntry(
            user: message,
            companion: "",
            timestamp: Date()
        )
        conversationHistory.append(entry)
        
        // Keep only recent history
        if conversationHistory.count > maxHistoryLength {
            conversationHistory.removeFirst()
        }
    }
    
    func getRecentContext() async -> String {
        let recentEntries = conversationHistory.suffix(5)
        return recentEntries.map { "\($0.timestamp): \($0.user)" }.joined(separator: "\n")
    }
    
    func getCurrentState() async -> String {
        return await getRecentContext()
    }
    
    func getConversationHistory() async -> String {
        return conversationHistory.map { "User: \($0.user), Companion: \($0.companion)" }.joined(separator: "\n")
    }
}

/// Long-term memory for significant interactions
class LongTermMemory: MemorySystem, Memory {
    private var significantMemories: [SignificantMemory] = []
    private var facts: [String] = []
    
    var name: String { "LongTermMemory" }
    
    func initialize() async {
        significantMemories = []
        facts = []
    }
    
    func addSignificantInteraction(input: String, response: String, emotionalState: EmotionalState) async {
        let memory = SignificantMemory(
            input: input,
            response: response,
            emotionalState: emotionalState,
            timestamp: Date()
        )
        significantMemories.append(memory)
    }
    
    func getRelevantMemories(for input: String) async -> String {
        // Simple keyword matching - could be enhanced with AI
        let keywords = input.lowercased().components(separatedBy: .whitespaces)
        let relevantMemories = significantMemories.filter { memory in
            keywords.contains { keyword in
                memory.input.lowercased().contains(keyword) ||
                memory.response.lowercased().contains(keyword)
            }
        }
        
        return relevantMemories.map { "\($0.timestamp): \($0.input) -> \($0.response)" }.joined(separator: "\n")
    }
    
    func getCurrentState() async -> String {
        return significantMemories.map { "\($0.timestamp): \($0.input)" }.joined(separator: "\n")
    }
    
    func retrieveContext(for query: String) async -> String {
        // Simple retrieval for now, could be more sophisticated with embeddings
        let relevantFacts = facts.filter { $0.lowercased().contains(query.lowercased()) }
        return relevantFacts.isEmpty ? "No specific long-term context." : "Relevant facts: \(relevantFacts.joined(separator: "; "))"
    }
    
    func addFact(_ fact: String) async {
        facts.append(fact)
        print("Long-Term Memory: Added fact: \(fact)")
    }
}

/// Episodic memory for specific events and experiences
class EpisodicMemory: MemorySystem, Memory {
    private var episodes: [Episode] = []
    
    var name: String { "EpisodicMemory" }
    
    func initialize() async {
        episodes = []
    }
    
    func addConversation(input: String, response: String, timestamp: Date) async {
        let episode = Episode(
            input: input,
            response: response,
            timestamp: timestamp
        )
        episodes.append(episode)
    }
    
    func getRelevantEpisodes(for input: String) async -> String {
        // Find episodes with similar context
        let recentEpisodes = episodes.suffix(10)
        return recentEpisodes.map { "\($0.timestamp): \($0.input)" }.joined(separator: "\n")
    }
    
    func getCurrentState() async -> String {
        return episodes.map { "\($0.timestamp): \($0.input)" }.joined(separator: "\n")
    }
}

/// Emotional memory for tracking emotional states
class EmotionalMemory: MemorySystem, Memory {
    private var emotionalHistory: [EmotionalEntry] = []
    private var currentState: EmotionalState = .neutral
    
    var name: String { "EmotionalMemory" }
    
    func initialize() async {
        emotionalHistory = []
        currentState = .neutral
    }
    
    func analyzeEmotionalState(_ input: String) async -> EmotionalState {
        // Simple emotional analysis - could be enhanced with AI
        let lowercased = input.lowercased()
        
        if lowercased.contains("happy") || lowercased.contains("joy") || lowercased.contains("excited") {
            return .joy
        } else if lowercased.contains("sad") || lowercased.contains("depressed") || lowercased.contains("down") {
            return .sadness
        } else if lowercased.contains("angry") || lowercased.contains("mad") || lowercased.contains("frustrated") {
            return .anger
        } else if lowercased.contains("love") || lowercased.contains("care") || lowercased.contains("affection") {
            return .joy
        } else {
            return .neutral
        }
    }
    
    func updateEmotionalState(_ state: EmotionalState) async {
        let entry = EmotionalEntry(
            state: state,
            timestamp: Date()
        )
        emotionalHistory.append(entry)
        currentState = state
    }
    
    func getCurrentState() async -> String {
        return "Current: \(currentState), History: \(emotionalHistory.count) entries"
    }
    
    func getCurrentEmotionalState() async -> EmotionalState {
        return currentState
    }
    
    func updateEmotionalState(to newState: EmotionalState) async {
        currentState = newState
        print("Emotional Memory: Updated state to \(newState.rawValue)")
    }
}

/// Data structures for memory systems

struct SignificantMemory {
    let input: String
    let response: String
    let emotionalState: EmotionalState
    let timestamp: Date
}

struct Episode {
    let input: String
    let response: String
    let timestamp: Date
}

struct EmotionalEntry {
    let state: EmotionalState
    let timestamp: Date
}

/// Emotional states
enum EmotionalState: String, CaseIterable {
    case neutral = "neutral"
    case joy = "joy"
    case sadness = "sadness"
    case anger = "anger"
    case surprise = "surprise"
    case fear = "fear"
    case disgust = "disgust"
}
