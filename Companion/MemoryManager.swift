import Foundation

/// Manages multiple memory systems
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
