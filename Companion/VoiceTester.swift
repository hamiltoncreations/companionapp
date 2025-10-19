import Foundation
import AVFoundation

/// Voice testing utility for optimizing gamer woman voice
class VoiceTester: ObservableObject {
    private let voiceManager: VoiceManager
    
    @Published var isTesting: Bool = false
    @Published var currentTestIndex: Int = 0
    @Published var testResults: [VoiceTestResult] = []
    
    init(voiceManager: VoiceManager) {
        self.voiceManager = voiceManager
    }
    
    // MARK: - Voice Testing Methods
    
    func runFullVoiceTest() {
        isTesting = true
        currentTestIndex = 0
        testResults.removeAll()
        
        let testPhrases = VoiceConfiguration.getTestPhrases()
        
        for (index, phrase) in testPhrases.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 3.0) {
                self.testPhrase(phrase, at: index)
            }
        }
        
        // Complete testing after all phrases
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(testPhrases.count) * 3.0) {
            self.isTesting = false
            self.analyzeResults()
        }
    }
    
    private func testPhrase(_ phrase: String, at index: Int) {
        currentTestIndex = index
        
        // Detect emotion for the phrase
        let emotion = detectEmotionFromText(phrase)
        
        // Speak the phrase
        voiceManager.speak(text: phrase, with: emotion)
        
        // Record test result
        let result = VoiceTestResult(
            phrase: phrase,
            emotion: emotion,
            timestamp: Date(),
            quality: estimateQuality(for: phrase, emotion: emotion)
        )
        
        testResults.append(result)
    }
    
    private func detectEmotionFromText(_ text: String) -> VoiceManager.VoiceEmotion {
        let lowercaseText = text.lowercased()
        
        // Gaming-specific emotions (highest priority)
        if lowercaseText.contains("poggers") || lowercaseText.contains("pog") || lowercaseText.contains("clutch") || lowercaseText.contains("sick") {
            return .poggers
        } else if lowercaseText.contains("epic") || lowercaseText.contains("awesome") || lowercaseText.contains("incredible") || lowercaseText.contains("perfect") {
            return .hyped
        } else if lowercaseText.contains("gaming") || lowercaseText.contains("game") || lowercaseText.contains("play") || lowercaseText.contains("win") {
            return .gaming
        } else if lowercaseText.contains("ugh") || lowercaseText.contains("seriously") || lowercaseText.contains("come on") || lowercaseText.contains("really") {
            return .salty
        } else if lowercaseText.contains("okay") || lowercaseText.contains("right") || lowercaseText.contains("got it") || lowercaseText.contains("sure") {
            return .focused
        } else if lowercaseText.contains("!") || lowercaseText.contains("amazing") || lowercaseText.contains("awesome") {
            return .excited
        } else {
            return .neutral
        }
    }
    
    private func estimateQuality(for phrase: String, emotion: VoiceManager.VoiceEmotion) -> Float {
        // Simple quality estimation based on phrase characteristics
        var quality: Float = 0.8 // Base quality
        
        // Boost quality for gaming expressions
        if emotion == .gaming || emotion == .hyped || emotion == .poggers {
            quality += 0.1
        }
        
        // Boost quality for energetic phrases
        if phrase.contains("!") || phrase.contains("epic") || phrase.contains("awesome") {
            quality += 0.05
        }
        
        return min(1.0, quality)
    }
    
    private func analyzeResults() {
        let averageQuality = testResults.map { $0.quality }.reduce(0, +) / Float(testResults.count)
        let emotionDistribution = Dictionary(grouping: testResults, by: { $0.emotion })
        
        print("🎤 Voice Test Results:")
        print("📊 Average Quality: \(String(format: "%.2f", averageQuality))")
        print("📈 Emotion Distribution:")
        
        for (emotion, results) in emotionDistribution {
            print("  \(emotion): \(results.count) tests")
        }
        
        // Provide recommendations
        provideRecommendations(averageQuality: averageQuality)
    }
    
    private func provideRecommendations(averageQuality: Float) {
        print("\n💡 Voice Optimization Recommendations:")
        
        if averageQuality < 0.7 {
            print("  • Consider adjusting base voice parameters")
            print("  • Check if enhanced voices are available")
            print("  • Verify EQ settings are optimal")
        } else if averageQuality < 0.85 {
            print("  • Fine-tune emotion-specific parameters")
            print("  • Adjust EQ settings for better clarity")
            print("  • Consider voice rate and pitch adjustments")
        } else {
            print("  • Voice quality is excellent!")
            print("  • Consider minor tweaks for perfection")
        }
    }
    
    // MARK: - Individual Emotion Testing
    
    func testGamingEmotions() {
        let gamingPhrases = [
            "Ready to game?",
            "That was epic!",
            "Let's win this!",
            "Perfect play!"
        ]
        
        for phrase in gamingPhrases {
            voiceManager.speak(text: phrase, with: .gaming)
            Thread.sleep(forTimeInterval: 2.0)
        }
    }
    
    func testHypedEmotions() {
        let hypedPhrases = [
            "YESSS! That was incredible!",
            "Amazing play!",
            "You're getting so good!",
            "That was perfect!"
        ]
        
        for phrase in hypedPhrases {
            voiceManager.speak(text: phrase, with: .hyped)
            Thread.sleep(forTimeInterval: 2.0)
        }
    }
    
    func testSaltyEmotions() {
        let saltyPhrases = [
            "Ugh, that was cheap...",
            "Seriously?",
            "Come on, that's not fair!",
            "Really? That's ridiculous!"
        ]
        
        for phrase in saltyPhrases {
            voiceManager.speak(text: phrase, with: .salty)
            Thread.sleep(forTimeInterval: 2.0)
        }
    }
    
    func testPoggersEmotions() {
        let poggersPhrases = [
            "That was absolutely poggers!",
            "POG! What a play!",
            "Sick moves!",
            "Clutch moment!"
        ]
        
        for phrase in poggersPhrases {
            voiceManager.speak(text: phrase, with: .poggers)
            Thread.sleep(forTimeInterval: 2.0)
        }
    }
}

// MARK: - Voice Test Result

struct VoiceTestResult {
    let phrase: String
    let emotion: VoiceManager.VoiceEmotion
    let timestamp: Date
    let quality: Float
}

// MARK: - Voice Quality Analyzer

class VoiceQualityAnalyzer {
    
    static func analyzeVoiceQuality(for results: [VoiceTestResult]) -> VoiceQualityReport {
        let averageQuality = results.map { $0.quality }.reduce(0, +) / Float(results.count)
        let emotionScores = Dictionary(grouping: results, by: { $0.emotion })
            .mapValues { $0.map { $0.quality }.reduce(0, +) / Float($0.count) }
        
        let recommendations = generateRecommendations(
            averageQuality: averageQuality,
            emotionScores: emotionScores
        )
        
        return VoiceQualityReport(
            overallQuality: averageQuality,
            emotionScores: emotionScores,
            recommendations: recommendations,
            testCount: results.count
        )
    }
    
    private static func generateRecommendations(
        averageQuality: Float,
        emotionScores: [VoiceManager.VoiceEmotion: Float]
    ) -> [String] {
        var recommendations: [String] = []
        
        if averageQuality < 0.7 {
            recommendations.append("Consider switching to enhanced voices")
            recommendations.append("Adjust base voice parameters")
            recommendations.append("Check EQ settings")
        }
        
        if let gamingScore = emotionScores[.gaming], gamingScore < 0.8 {
            recommendations.append("Optimize gaming emotion parameters")
        }
        
        if let hypedScore = emotionScores[.hyped], hypedScore < 0.8 {
            recommendations.append("Boost hyped emotion energy")
        }
        
        if let saltyScore = emotionScores[.salty], saltyScore < 0.8 {
            recommendations.append("Enhance salty emotion attitude")
        }
        
        return recommendations
    }
}

struct VoiceQualityReport {
    let overallQuality: Float
    let emotionScores: [VoiceManager.VoiceEmotion: Float]
    let recommendations: [String]
    let testCount: Int
}
