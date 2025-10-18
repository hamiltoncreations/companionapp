import Foundation

/// Manages companion tools
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
