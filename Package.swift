// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Companion",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .executable(name: "Companion", targets: ["Companion"])
    ],
    dependencies: [
        // OpenAI Swift - For cloud AI integration
        .package(url: "https://github.com/MacPaw/OpenAI", from: "0.2.0"),
        
        // Swift Collections - Enhanced collection types
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        
        // Swift Algorithms - Additional algorithms
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "Companion",
            dependencies: [
                "OpenAI",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            path: "Companion",
            sources: [
                "CompanionApp.swift",
                "CompanionManager.swift", 
                "CompanionAI.swift",
                "Companion3DModel.swift",
                "AIProvider.swift",
                "CloudAIProvider.swift",
                "AIManager.swift",
                "CompanionOrchestrator.swift",
                "MemorySystems.swift",
                "CompanionTools.swift",
                "VoiceManager.swift",
                "PersonalityEngine.swift",
                "OpenAIProvider.swift",
                "RuleBasedAIProvider.swift",
                "MemoryManager.swift",
                "ToolManager.swift"
            ]
        )
    ]
)
