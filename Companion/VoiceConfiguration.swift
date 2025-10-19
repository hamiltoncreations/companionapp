import Foundation
import AVFoundation

/// Voice configuration helper for optimizing young gamer woman voice
class VoiceConfiguration {
    
    // MARK: - Voice Quality Settings
    
    static let gamerVoiceSettings = GamerVoiceSettings()
    
    struct GamerVoiceSettings {
        // Base voice parameters optimized for young female gamer
        let baseRate: Float = 0.35        // Slightly faster for energy
        let basePitch: Float = 1.15       // Higher pitch for young female
        let baseVolume: Float = 0.9      // Slightly lower for natural sound
        
        // Gaming-specific voice characteristics
        let gamingRate: Float = 1.15     // 15% faster for gaming energy
        let gamingPitch: Float = 1.25    // 25% higher pitch for excitement
        let gamingVolume: Float = 1.05   // 5% louder for energy
        
        // Hyped voice characteristics
        let hypedRate: Float = 1.3       // 30% faster for maximum hype
        let hypedPitch: Float = 1.4       // 40% higher pitch for excitement
        let hypedVolume: Float = 1.15     // 15% louder for energy
        
        // Focused voice characteristics
        let focusedRate: Float = 0.9     // 10% slower for concentration
        let focusedPitch: Float = 1.1     // 10% higher for alertness
        let focusedVolume: Float = 0.95   // 5% quieter for focus
        
        // Salty voice characteristics
        let saltyRate: Float = 1.0       // Normal rate with attitude
        let saltyPitch: Float = 1.2      // 20% higher for frustration
        let saltyVolume: Float = 1.1     // 10% louder for emphasis
        
        // Poggers voice characteristics
        let poggersRate: Float = 1.25    // 25% faster for excitement
        let poggersPitch: Float = 1.35    // 35% higher pitch for hype
        let poggersVolume: Float = 1.2    // 20% louder for energy
    }
    
    // MARK: - EQ Settings for Gaming Voice
    
    struct GamingEQSettings {
        // Gaming energy EQ (boost mid-high frequencies)
        static let gaming: [Float] = [0, 0, 0, 0, 0, 2.0, 3.0, 2.5, 1.5, 0]
        
        // Hyped energy EQ (maximum boost)
        static let hyped: [Float] = [0, 0, 0, 0, 0, 0, 4.0, 5.0, 3.0, 2.0]
        
        // Focused clarity EQ (slight boost in clarity frequencies)
        static let focused: [Float] = [0, 0, 0, 0, 1.0, 1.5, 1.0, 0, 0, 0]
        
        // Salty attitude EQ (boost mid frequencies)
        static let salty: [Float] = [0, 0, 0, 0, 2.0, 2.5, 1.5, 0, 0, 0]
        
        // Poggers energy EQ (maximum energy across all frequencies)
        static let poggers: [Float] = [0, 0, 0, 0, 0, 3.0, 4.0, 4.5, 3.5, 2.5]
    }
    
    // MARK: - Voice Selection Priority
    
    static func getPreferredVoices() -> [String] {
        return [
            // Enhanced female voices (highest quality)
            "Samantha (Enhanced)",
            "Karen (Enhanced)", 
            "Susan (Enhanced)",
            "Victoria (Enhanced)",
            "Kate (Enhanced)",
            
            // Standard female voices
            "Samantha",
            "Karen",
            "Susan", 
            "Victoria",
            "Kate",
            
            // Fallback voices
            "Enhanced",
            "Default"
        ]
    }
    
    // MARK: - Gaming Expression Patterns
    
    struct GamingExpressions {
        static let poggersWords = ["poggers", "pog", "clutch", "sick", "epic", "legendary"]
        static let hypedWords = ["awesome", "amazing", "incredible", "perfect", "yes", "wow"]
        static let gamingWords = ["gaming", "game", "play", "win", "victory", "defeat"]
        static let saltyWords = ["ugh", "seriously", "come on", "really", "unfair", "cheap"]
        static let focusedWords = ["okay", "right", "got it", "sure", "understood", "ready"]
    }
    
    // MARK: - Voice Quality Optimization
    
    static func optimizeForGaming() -> VoiceOptimizationSettings {
        return VoiceOptimizationSettings(
            useEnhancedVoices: true,
            enableRealTimeEQ: true,
            enableEmotionDetection: true,
            enableLipSync: true,
            enableVoiceModulation: true
        )
    }
    
    struct VoiceOptimizationSettings {
        let useEnhancedVoices: Bool
        let enableRealTimeEQ: Bool
        let enableEmotionDetection: Bool
        let enableLipSync: Bool
        let enableVoiceModulation: Bool
    }
    
    // MARK: - Voice Testing Utilities
    
    static func getTestPhrases() -> [String] {
        return [
            "Hey there! Ready to game?",
            "That was absolutely poggers!",
            "Epic play, you're getting so good!",
            "Ugh, that was such a cheap shot...",
            "Okay, let's focus and win this!",
            "YESSS! That was incredible!",
            "I'm so hyped for this match!",
            "Come on, you've got this!"
        ]
    }
    
    // MARK: - Voice Quality Metrics
    
    static func getVoiceQualityMetrics() -> VoiceQualityMetrics {
        return VoiceQualityMetrics(
            clarity: 0.9,      // High clarity for gaming communication
            energy: 0.95,     // High energy for gaming excitement
            naturalness: 0.85, // Good naturalness while maintaining gaming character
            expressiveness: 0.9 // High expressiveness for gaming emotions
        )
    }
    
    struct VoiceQualityMetrics {
        let clarity: Float      // How clear the voice is (0-1)
        let energy: Float       // How energetic the voice is (0-1)
        let naturalness: Float // How natural the voice sounds (0-1)
        let expressiveness: Float // How expressive the voice is (0-1)
    }
}
