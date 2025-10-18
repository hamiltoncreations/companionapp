# Maddie Companion App

A sophisticated 3D animated companion app with AI capabilities, built with SwiftUI, SceneKit, and OpenAI integration. Features a witty, edgy, and uncensored AI personality.

## Features

- 🎭 3D animated character with SceneKit
- 🗣️ Text-to-speech synthesis
- 🎤 Speech recognition
- 💬 Interactive conversation with AI
- 🧠 Advanced memory systems (short-term, long-term, episodic, emotional)
- 🛠️ Tool integration (calendar, weather, reminders, music, photos)
- 🤖 OpenAI ChatGPT integration for intelligent conversations
- 📱 Cross-platform (iOS/macOS)

## Requirements

- iOS 14.0+ / macOS 11.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

### Prerequisites
- Xcode 15.0+
- Swift 5.9+
- OpenAI API key

### Initial Setup
1. Clone the repository
2. Open the project in Xcode
3. Build and run on your device or simulator
4. Grant microphone and speech recognition permissions when prompted

### AI Setup

#### OpenAI/ChatGPT (Recommended - Simple & Reliable)
The app automatically detects your OpenAI API key from a secure `.env` file.

**To get your OpenAI API key:**
1. Go to https://platform.openai.com/api-keys
2. Create a new API key
3. Follow the secure setup guide in `API_KEY_SETUP.md`

**🔒 Security**: The app uses `.env` files for secure API key storage. Never commit API keys to version control!

### AI Recommendations
- **Development/Testing**: OpenAI GPT-3.5-turbo (fast, cheap)
- **Production**: OpenAI GPT-4 (best quality)
- **Fallback**: Rule-based AI (no internet required)

## Usage

- Type a message in the text field and tap "Speak" to have the companion respond
- Use "Listen" to speak to the companion using voice recognition
- Use "Stop" to stop the companion from speaking
- The 3D character will animate while speaking

## Architecture

### Core Components
- `CompanionApp.swift`: Main app entry point and UI
- `CompanionManager.swift`: Core logic for 3D rendering, speech synthesis, and speech recognition
- `CompanionOrchestrator.swift`: LangChain Swift orchestration layer
- `Info.plist`: App permissions and configuration

### AI Architecture
- `AIProvider.swift`: Protocol for all AI providers
- `AIManager.swift`: AI management with dependency injection
- `CloudAIProvider.swift`: Base class for API providers
- `OpenAIProvider.swift`: OpenAI ChatGPT integration
- `RuleBasedAIProvider.swift`: Fallback rule-based AI

### Memory Systems
- `MemorySystems.swift`: Multiple memory system implementations
  - ShortTermMemory: Current conversation context
  - LongTermMemory: Significant interactions and relationships
  - EpisodicMemory: Specific events and experiences
  - EmotionalMemory: Emotional state tracking

### Tool Integration
- `CompanionTools.swift`: Tool implementations
  - CalendarTool: Event management
  - WeatherTool: Weather information
  - ReminderTool: Task management
  - MusicTool: Music control
  - PhotoTool: Photo management

## Development Status

### ✅ Completed
- [x] 3D animated character with SceneKit
- [x] Text-to-speech synthesis
- [x] Speech recognition
- [x] LangChain Swift integration
- [x] Advanced memory systems
- [x] Tool integration
- [x] Agent orchestration
- [x] Multiple AI model support

### 🔄 In Progress
- [ ] Model integration and testing
- [ ] Xcode project setup
- [ ] App Store optimization

### 🚀 Future Enhancements
- [ ] More sophisticated 3D character models
- [ ] Advanced lip-sync animation
- [ ] Cloud API integration (OpenAI/Claude)
- [ ] Customizable companion appearance
- [ ] Emotion-based animations
- [ ] Voice cloning capabilities
- [ ] Model download system
- [ ] Advanced memory AI
- [ ] Multi-modal interactions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your preferred AI model
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- LangChain Swift for AI orchestration
- Core ML for local AI processing
- SceneKit for 3D graphics
- Apple's Speech framework for voice recognition
