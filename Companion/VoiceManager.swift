import Foundation
import AVFoundation
import Speech

/// Advanced voice synthesis manager with personality-aware modulation
class VoiceManager: NSObject, ObservableObject {
    @Published var isSpeaking: Bool = false
    @Published var currentEmotion: VoiceEmotion = .neutral
    
    private var speechSynthesizer: AVSpeechSynthesizer
    private var audioEngine: AVAudioEngine
    private var audioPlayerNode: AVAudioPlayerNode
    private var audioUnitEQ: AVAudioUnitEQ
    
    // Voice configuration
    private var currentVoice: AVSpeechSynthesisVoice?
    private var baseRate: Float = 0.3
    private var basePitch: Float = 1.0
    private var baseVolume: Float = 1.0
    
    // Phoneme timing for lip-sync
    private var phonemeTimings: [PhonemeTiming] = []
    private var currentPhonemeIndex: Int = 0
    
    enum VoiceEmotion {
        case neutral, excited, sad, angry, thinking, sarcastic, witty, gaming, hyped, focused, salty, poggers
    }
    
    struct PhonemeTiming {
        let phoneme: String
        let startTime: TimeInterval
        let duration: TimeInterval
        let intensity: Float
    }
    
    override init() {
        self.speechSynthesizer = AVSpeechSynthesizer()
        self.audioEngine = AVAudioEngine()
        self.audioPlayerNode = AVAudioPlayerNode()
        self.audioUnitEQ = AVAudioUnitEQ(numberOfBands: 10)
        
        super.init()
        
        // Setup basic voice first for immediate use
        setupVoice()
        
        // Defer heavy audio engine setup
        Task {
            await setupAudioEngineAsync()
        }
    }
    
    private func setupAudioEngineAsync() async {
        print("🚀 Setting up audio engine asynchronously...")
        
        // Configure audio engine for enhanced voice processing
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(audioUnitEQ)
        
        // Connect audio nodes
        audioEngine.connect(audioPlayerNode, to: audioUnitEQ, format: nil)
        audioEngine.connect(audioUnitEQ, to: audioEngine.mainMixerNode, format: nil)
        
        // Configure EQ for voice enhancement
        configureEQ()
        
        do {
            try audioEngine.start()
            print("✅ Audio engine started successfully")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
        }
    }
    
    private func configureEQ() {
        // Configure 10-band EQ for voice enhancement
        let frequencies: [Float] = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        
        for (index, frequency) in frequencies.enumerated() {
            let filter = audioUnitEQ.bands[index]
            filter.frequency = frequency
            filter.filterType = .parametric
            filter.bandwidth = 1.0
            filter.gain = 0.0 // Neutral gain
        }
    }
    
    private func setupVoice() {
        // Select the best available voice for young female gamer
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Prioritize enhanced female voices with young characteristics
        let preferredVoices = [
            // Enhanced female voices (highest quality)
            voices.first(where: { $0.quality == .enhanced && $0.name.contains("Samantha") }),
            voices.first(where: { $0.quality == .enhanced && $0.name.contains("Karen") }),
            voices.first(where: { $0.quality == .enhanced && $0.name.contains("Susan") }),
            voices.first(where: { $0.quality == .enhanced && $0.name.contains("Victoria") }),
            voices.first(where: { $0.quality == .enhanced && $0.name.contains("Kate") }),
            
            // Standard female voices as fallback
            voices.first(where: { $0.name.contains("Samantha") }),
            voices.first(where: { $0.name.contains("Karen") }),
            voices.first(where: { $0.name.contains("Susan") }),
            voices.first(where: { $0.name.contains("Victoria") }),
            voices.first(where: { $0.name.contains("Kate") }),
            
            // Any enhanced voice
            voices.first(where: { $0.quality == .enhanced }),
            
            // Any English voice
            voices.first(where: { $0.language.hasPrefix("en") })
        ]
        
        currentVoice = preferredVoices.compactMap { $0 }.first ?? AVSpeechSynthesisVoice(language: "en-US")
        
        // Set gamer-optimized voice parameters using configuration
        let settings = VoiceConfiguration.gamerVoiceSettings
        baseRate = settings.baseRate
        basePitch = settings.basePitch
        baseVolume = settings.baseVolume
        
        speechSynthesizer.delegate = self
    }
    
    // MARK: - Main Speech Methods
    
    func speak(text: String, with emotion: VoiceEmotion = .neutral) {
        guard !text.isEmpty else { return }
        
        currentEmotion = emotion
        isSpeaking = true
        
        // Process text for personality and emotion
        let processedText = processTextForPersonality(text, emotion: emotion)
        
        // Generate phoneme timings for lip-sync
        generatePhonemeTimings(for: processedText)
        
        // Create utterance with emotion-based parameters
        let utterance = createEmotionalUtterance(text: processedText, emotion: emotion)
        
        // Apply voice modulation
        applyVoiceModulation(utterance, emotion: emotion)
        
        // Speak with enhanced processing
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        phonemeTimings.removeAll()
        currentPhonemeIndex = 0
    }
    
    // MARK: - Text Processing
    
    private func processTextForPersonality(_ text: String, emotion: VoiceEmotion) -> String {
        var processedText = text
        
        // Add natural pauses for all emotions
        processedText = addNaturalPauses(processedText)
        
        // Add personality-based punctuation and emphasis
        switch emotion {
        case .excited:
            processedText = addExcitementMarkers(processedText)
        case .sarcastic:
            processedText = addSarcasmMarkers(processedText)
        case .witty:
            processedText = addWitMarkers(processedText)
        case .thinking:
            processedText = addThinkingMarkers(processedText)
        case .angry:
            processedText = addAngerMarkers(processedText)
        case .sad:
            processedText = addSadnessMarkers(processedText)
        case .gaming:
            processedText = addGamingMarkers(processedText)
        case .hyped:
            processedText = addHypedMarkers(processedText)
        case .focused:
            processedText = addFocusedMarkers(processedText)
        case .salty:
            processedText = addSaltyMarkers(processedText)
        case .poggers:
            processedText = addPoggersMarkers(processedText)
        case .neutral:
            break
        }
        
        return processedText
    }
    
    private func addExcitementMarkers(_ text: String) -> String {
        // Add emphasis and excitement markers
        return text.replacingOccurrences(of: "!", with: "! ")
            .replacingOccurrences(of: "amazing", with: "a-MAZING")
            .replacingOccurrences(of: "incredible", with: "in-CRED-ible")
    }
    
    private func addSarcasmMarkers(_ text: String) -> String {
        // Add sarcastic emphasis
        return text.replacingOccurrences(of: "really", with: "re-ally")
            .replacingOccurrences(of: "sure", with: "suuure")
            .replacingOccurrences(of: "great", with: "greeeat")
    }
    
    private func addWitMarkers(_ text: String) -> String {
        // Add witty emphasis and pauses
        return text.replacingOccurrences(of: "but", with: "but...")
            .replacingOccurrences(of: "however", with: "how-ever")
            .replacingOccurrences(of: "well", with: "well...")
            .replacingOccurrences(of: "actually", with: "actually...")
    }
    
    private func addThinkingMarkers(_ text: String) -> String {
        // Add thinking pauses
        return text.replacingOccurrences(of: ".", with: "...")
            .replacingOccurrences(of: ",", with: ",,,")
            .replacingOccurrences(of: "?", with: "?..")
            .replacingOccurrences(of: "!", with: "!..")
    }
    
    private func addAngerMarkers(_ text: String) -> String {
        // Add anger emphasis
        return text.replacingOccurrences(of: "!", with: "!!")
            .replacingOccurrences(of: "no", with: "NO")
    }
    
    private func addNaturalPauses(_ text: String) -> String {
        // Add natural pauses for better speech flow
        return text.replacingOccurrences(of: ". ", with: "... ")
            .replacingOccurrences(of: ", ", with: ",, ")
            .replacingOccurrences(of: "? ", with: "?.. ")
            .replacingOccurrences(of: "! ", with: "!.. ")
            .replacingOccurrences(of: ": ", with: ":.. ")
    }
    
    private func addSadnessMarkers(_ text: String) -> String {
        // Add sadness markers
        return text.replacingOccurrences(of: ".", with: "...")
            .replacingOccurrences(of: "sorry", with: "so sorry")
    }
    
    private func addGamingMarkers(_ text: String) -> String {
        // Add gaming-specific emphasis and expressions
        return text.replacingOccurrences(of: "epic", with: "E-PIC")
            .replacingOccurrences(of: "awesome", with: "awe-SOME")
            .replacingOccurrences(of: "cool", with: "cooool")
            .replacingOccurrences(of: "nice", with: "niice")
            .replacingOccurrences(of: "wow", with: "wooow")
            .replacingOccurrences(of: "!", with: "! ")
    }
    
    private func addHypedMarkers(_ text: String) -> String {
        // Add hyped gaming energy
        return text.replacingOccurrences(of: "!", with: "!!")
            .replacingOccurrences(of: "yes", with: "YESSS")
            .replacingOccurrences(of: "amazing", with: "a-MAZING")
            .replacingOccurrences(of: "incredible", with: "in-CRED-ible")
            .replacingOccurrences(of: "perfect", with: "per-FECT")
    }
    
    private func addFocusedMarkers(_ text: String) -> String {
        // Add focused gaming intensity
        return text.replacingOccurrences(of: "okay", with: "okay...")
            .replacingOccurrences(of: "right", with: "right...")
            .replacingOccurrences(of: "got it", with: "got it...")
            .replacingOccurrences(of: "sure", with: "sure...")
    }
    
    private func addSaltyMarkers(_ text: String) -> String {
        // Add salty/frustrated gaming expressions
        return text.replacingOccurrences(of: "ugh", with: "ughhh")
            .replacingOccurrences(of: "seriously", with: "ser-iously")
            .replacingOccurrences(of: "come on", with: "come ON")
            .replacingOccurrences(of: "really", with: "re-ally")
    }
    
    private func addPoggersMarkers(_ text: String) -> String {
        // Add poggers/hype expressions
        return text.replacingOccurrences(of: "poggers", with: "POG-GERS")
            .replacingOccurrences(of: "pog", with: "POG")
            .replacingOccurrences(of: "clutch", with: "CLUTCH")
            .replacingOccurrences(of: "sick", with: "SICK")
            .replacingOccurrences(of: "!", with: "! ")
    }
    
    // MARK: - Phoneme Generation
    
    private func generatePhonemeTimings(for text: String) {
        phonemeTimings.removeAll()
        currentPhonemeIndex = 0
        
        // Simple phoneme mapping for basic lip-sync
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        var currentTime: TimeInterval = 0.0
        
        for word in words {
            let phonemes = generatePhonemes(for: word)
            let wordDuration = estimateWordDuration(word)
            let phonemeDuration = wordDuration / Double(phonemes.count)
            
            for (index, phoneme) in phonemes.enumerated() {
                let timing = PhonemeTiming(
                    phoneme: phoneme,
                    startTime: currentTime + (Double(index) * phonemeDuration),
                    duration: phonemeDuration,
                    intensity: calculatePhonemeIntensity(phoneme)
                )
                phonemeTimings.append(timing)
            }
            
            currentTime += wordDuration + 0.1 // Small pause between words
        }
    }
    
    private func generatePhonemes(for word: String) -> [String] {
        // Simple phoneme mapping for basic lip-sync
        let vowels = ["a", "e", "i", "o", "u"]
        let consonants = ["b", "p", "m", "f", "v", "d", "t", "n", "l", "r", "s", "z", "k", "g", "h"]
        
        var phonemes: [String] = []
        
        for character in word.lowercased() {
            let char = String(character)
            if vowels.contains(char) {
                phonemes.append("open") // Open mouth for vowels
            } else if consonants.contains(char) {
                phonemes.append("closed") // Closed mouth for consonants
            } else {
                phonemes.append("neutral") // Neutral for other characters
            }
        }
        
        return phonemes
    }
    
    private func estimateWordDuration(_ word: String) -> TimeInterval {
        // Estimate duration based on word length and complexity
        let baseDuration = 0.2
        let lengthMultiplier = Double(word.count) * 0.05
        let complexityBonus = word.contains("th") || word.contains("sh") ? 0.1 : 0.0
        
        return baseDuration + lengthMultiplier + complexityBonus
    }
    
    private func calculatePhonemeIntensity(_ phoneme: String) -> Float {
        switch phoneme {
        case "open":
            return 1.0
        case "closed":
            return 0.3
        case "neutral":
            return 0.6
        default:
            return 0.5
        }
    }
    
    // MARK: - Voice Modulation
    
    private func createEmotionalUtterance(text: String, emotion: VoiceEmotion) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = currentVoice
        
        // Set emotion-based parameters
        switch emotion {
        case .neutral:
            utterance.rate = baseRate
            utterance.pitchMultiplier = basePitch
            utterance.volume = baseVolume
        case .excited:
            utterance.rate = baseRate * 1.1
            utterance.pitchMultiplier = basePitch * 1.2
            utterance.volume = baseVolume * 1.1
        case .sad:
            utterance.rate = baseRate * 0.7
            utterance.pitchMultiplier = basePitch * 0.8
            utterance.volume = baseVolume * 0.9
        case .angry:
            utterance.rate = baseRate * 1.05
            utterance.pitchMultiplier = basePitch * 1.3
            utterance.volume = baseVolume * 1.2
        case .thinking:
            utterance.rate = baseRate * 0.8
            utterance.pitchMultiplier = basePitch * 0.9
            utterance.volume = baseVolume * 0.8
        case .sarcastic:
            utterance.rate = baseRate * 0.9
            utterance.pitchMultiplier = basePitch * 1.1
            utterance.volume = baseVolume * 1.0
        case .witty:
            utterance.rate = baseRate * 1.05
            utterance.pitchMultiplier = basePitch * 1.05
            utterance.volume = baseVolume * 1.0
        case .gaming:
            let settings = VoiceConfiguration.gamerVoiceSettings
            utterance.rate = baseRate * settings.gamingRate
            utterance.pitchMultiplier = basePitch * settings.gamingPitch
            utterance.volume = baseVolume * settings.gamingVolume
        case .hyped:
            let settings = VoiceConfiguration.gamerVoiceSettings
            utterance.rate = baseRate * settings.hypedRate
            utterance.pitchMultiplier = basePitch * settings.hypedPitch
            utterance.volume = baseVolume * settings.hypedVolume
        case .focused:
            let settings = VoiceConfiguration.gamerVoiceSettings
            utterance.rate = baseRate * settings.focusedRate
            utterance.pitchMultiplier = basePitch * settings.focusedPitch
            utterance.volume = baseVolume * settings.focusedVolume
        case .salty:
            let settings = VoiceConfiguration.gamerVoiceSettings
            utterance.rate = baseRate * settings.saltyRate
            utterance.pitchMultiplier = basePitch * settings.saltyPitch
            utterance.volume = baseVolume * settings.saltyVolume
        case .poggers:
            let settings = VoiceConfiguration.gamerVoiceSettings
            utterance.rate = baseRate * settings.poggersRate
            utterance.pitchMultiplier = basePitch * settings.poggersPitch
            utterance.volume = baseVolume * settings.poggersVolume
        }
        
        return utterance
    }
    
    private func applyVoiceModulation(_ utterance: AVSpeechUtterance, emotion: VoiceEmotion) {
        // Apply EQ adjustments based on emotion
        switch emotion {
        case .excited:
            adjustEQForExcitement()
        case .sad:
            adjustEQForSadness()
        case .angry:
            adjustEQForAnger()
        case .thinking:
            adjustEQForThinking()
        case .gaming:
            adjustEQForGaming()
        case .hyped:
            adjustEQForHyped()
        case .focused:
            adjustEQForFocused()
        case .salty:
            adjustEQForSalty()
        case .poggers:
            adjustEQForPoggers()
        default:
            resetEQ()
        }
    }
    
    private func adjustEQForExcitement() {
        // Boost high frequencies for excitement
        audioUnitEQ.bands[7].gain = 3.0 // 4kHz
        audioUnitEQ.bands[8].gain = 4.0 // 8kHz
        audioUnitEQ.bands[9].gain = 2.0 // 16kHz
    }
    
    private func adjustEQForSadness() {
        // Reduce high frequencies for sadness
        audioUnitEQ.bands[6].gain = -2.0 // 2kHz
        audioUnitEQ.bands[7].gain = -3.0 // 4kHz
        audioUnitEQ.bands[8].gain = -2.0 // 8kHz
    }
    
    private func adjustEQForAnger() {
        // Boost mid frequencies for anger
        audioUnitEQ.bands[4].gain = 2.0 // 500Hz
        audioUnitEQ.bands[5].gain = 3.0 // 1kHz
        audioUnitEQ.bands[6].gain = 2.0 // 2kHz
    }
    
    private func adjustEQForThinking() {
        // Slight reduction in high frequencies for thinking
        audioUnitEQ.bands[7].gain = -1.0 // 4kHz
        audioUnitEQ.bands[8].gain = -1.0 // 8kHz
    }
    
    private func resetEQ() {
        // Reset all EQ bands to neutral
        for band in audioUnitEQ.bands {
            band.gain = 0.0
        }
    }
    
    private func adjustEQForGaming() {
        // Use configuration for gaming EQ
        let eqSettings = VoiceConfiguration.GamingEQSettings.gaming
        for (index, gain) in eqSettings.enumerated() {
            if index < audioUnitEQ.bands.count {
                audioUnitEQ.bands[index].gain = gain
            }
        }
    }
    
    private func adjustEQForHyped() {
        // Use configuration for hyped EQ
        let eqSettings = VoiceConfiguration.GamingEQSettings.hyped
        for (index, gain) in eqSettings.enumerated() {
            if index < audioUnitEQ.bands.count {
                audioUnitEQ.bands[index].gain = gain
            }
        }
    }
    
    private func adjustEQForFocused() {
        // Use configuration for focused EQ
        let eqSettings = VoiceConfiguration.GamingEQSettings.focused
        for (index, gain) in eqSettings.enumerated() {
            if index < audioUnitEQ.bands.count {
                audioUnitEQ.bands[index].gain = gain
            }
        }
    }
    
    private func adjustEQForSalty() {
        // Use configuration for salty EQ
        let eqSettings = VoiceConfiguration.GamingEQSettings.salty
        for (index, gain) in eqSettings.enumerated() {
            if index < audioUnitEQ.bands.count {
                audioUnitEQ.bands[index].gain = gain
            }
        }
    }
    
    private func adjustEQForPoggers() {
        // Use configuration for poggers EQ
        let eqSettings = VoiceConfiguration.GamingEQSettings.poggers
        for (index, gain) in eqSettings.enumerated() {
            if index < audioUnitEQ.bands.count {
                audioUnitEQ.bands[index].gain = gain
            }
        }
    }
    
    // MARK: - Lip-sync Support
    
    func getCurrentPhoneme() -> PhonemeTiming? {
        guard currentPhonemeIndex < phonemeTimings.count else { return nil }
        return phonemeTimings[currentPhonemeIndex]
    }
    
    func advancePhoneme() {
        currentPhonemeIndex += 1
    }
    
    func getMouthOpenness() -> Float {
        guard let currentPhoneme = getCurrentPhoneme() else { return 0.5 }
        return currentPhoneme.intensity
    }
    
    // MARK: - Voice Configuration
    
    func setVoiceRate(_ rate: Float) {
        baseRate = max(0.1, min(1.0, rate))
    }
    
    func setVoicePitch(_ pitch: Float) {
        basePitch = max(0.5, min(2.0, pitch))
    }
    
    func setVoiceVolume(_ volume: Float) {
        baseVolume = max(0.0, min(1.0, volume))
    }
    
    func setVoice(_ voice: AVSpeechSynthesisVoice) {
        currentVoice = voice
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.phonemeTimings.removeAll()
            self.currentPhonemeIndex = 0
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
}
