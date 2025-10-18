import Foundation
import EventKit
import CoreLocation

/// Protocol for companion tools
protocol Tool {
    var name: String { get }
    var description: String { get }
    func execute(input: String) async -> String
}

/// Calendar tool for managing events
@available(macOS 14.0, iOS 17.0, *)
class CalendarTool: Tool {
    let name = "Calendar"
    let description = "Manage calendar events and appointments"
    
    private let eventStore = EKEventStore()
    
    @available(macOS 14.0, iOS 17.0, *)
    func execute(input: String) async -> String {
        // Request calendar access
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            return await handleCalendarRequest(input)
        case .notDetermined:
            if #available(iOS 17.0, *) {
                let granted = try? await eventStore.requestFullAccessToEvents()
                if granted == true {
                    return await handleCalendarRequest(input)
                } else {
                    return "I need calendar access to help with events."
                }
            } else {
                // For iOS 15-16, use the older API
                let granted = try? await eventStore.requestAccess(to: .event)
                if granted == true {
                    return await handleCalendarRequest(input)
                } else {
                    return "I need calendar access to help with events."
                }
            }
        case .denied, .restricted:
            return "I don't have access to your calendar. Please enable it in Settings."
        case .fullAccess:
            return await handleCalendarRequest(input)
        case .writeOnly:
            return "Calendar access is limited. I can't read your events with write-only access."
        @unknown default:
            return "I'm having trouble accessing your calendar."
        }
    }
    
    private func handleCalendarRequest(_ input: String) async -> String {
        // Simple calendar operations
        if input.lowercased().contains("schedule") || input.lowercased().contains("appointment") {
            return "I can help you schedule events. What would you like to schedule?"
        } else if input.lowercased().contains("today") || input.lowercased().contains("events") {
            return await getTodaysEvents()
        } else {
            return "I can help with calendar events. What would you like to do?"
        }
    }
    
    private func getTodaysEvents() async -> String {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        if events.isEmpty {
            return "You have no events scheduled for today."
        } else {
            let eventList = events.map { "• \($0.title ?? "Untitled Event") at \($0.startDate)" }.joined(separator: "\n")
            return "Today's events:\n\(eventList)"
        }
    }
}

/// Weather tool for weather information
class WeatherTool: Tool {
    let name = "Weather"
    let description = "Get weather information"
    
    func execute(input: String) async -> String {
        if input.lowercased().contains("weather") {
            return "I can check the weather for you. What location would you like to know about?"
        } else {
            return "I can help with weather information. What would you like to know?"
        }
    }
}

/// Reminder tool for managing reminders
class ReminderTool: Tool {
    let name = "Reminders"
    let description = "Manage reminders and tasks"
    
    func execute(input: String) async -> String {
        if input.lowercased().contains("remind") || input.lowercased().contains("reminder") {
            return "I can help you set reminders. What would you like to be reminded about?"
        } else {
            return "I can help with reminders. What would you like to be reminded about?"
        }
    }
}

/// Music tool for music control
class MusicTool: Tool {
    let name = "Music"
    let description = "Control music playback"
    
    func execute(input: String) async -> String {
        if input.lowercased().contains("play") || input.lowercased().contains("music") {
            return "I can help you with music. What would you like to play?"
        } else {
            return "I can help with music. What would you like to do?"
        }
    }
}

/// Photo tool for photo management
class PhotoTool: Tool {
    let name = "Photos"
    let description = "Manage photos and memories"
    
    func execute(input: String) async -> String {
        if input.lowercased().contains("photo") || input.lowercased().contains("picture") {
            return "I can help you with photos. What would you like to do with your photos?"
        } else {
            return "I can help with photos. What would you like to do?"
        }
    }
}

/// Tool execution manager
class ToolExecutor {
    private let tools: [Tool]
    
    init(tools: [Tool]) {
        self.tools = tools
    }
    
    func executeTool(named name: String, with input: String) async -> String {
        guard let tool = tools.first(where: { $0.name == name }) else {
            return "I don't have access to the \(name) tool."
        }
        
        return await tool.execute(input: input)
    }
    
    func getAvailableTools() -> [String] {
        return tools.map { $0.name }
    }
}
