import Foundation
import SceneKit
import AVFoundation
import Speech
#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

class CompanionManager: NSObject, ObservableObject {
    @Published var userInput: String = ""
    @Published var isSpeaking: Bool = false
    @Published var isListening: Bool = false
    
    let scene: SCNScene
    private var companionModel: Companion3DModel?
    private var orchestrator: CompanionOrchestrator
    private var voiceManager: VoiceManager
    private var audioEngine: AVAudioEngine
    private var speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // Lip-sync timer
    private var lipSyncTimer: Timer?
    
    override init() {
        // Initialize 3D scene
        self.scene = SCNScene()
        
        // Initialize AI orchestrator with proper AI libraries
        self.orchestrator = CompanionOrchestrator()
        
        // Initialize enhanced voice manager
        self.voiceManager = VoiceManager()
        self.audioEngine = AVAudioEngine()
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        
        super.init()
        
        setupScene()
        setupAudio()
        requestPermissions()
        
        // Load AI orchestrator
        Task {
            do {
                try await orchestrator.load()
            } catch {
                print("❌ Failed to load AI orchestrator: \(error)")
            }
        }
    }
    
    private func setupScene() {
        // Create enhanced 3D companion model
        companionModel = Companion3DModel()
        companionModel?.position = SCNVector3(0, 0, 0)
        
        // Add gentle floating animation
        let floatUp = SCNAction.moveBy(x: 0, y: 0.1, z: 0, duration: 2.0)
        let floatDown = SCNAction.moveBy(x: 0, y: -0.1, z: 0, duration: 2.0)
        let floatSequence = SCNAction.sequence([floatUp, floatDown])
        let repeatFloat = SCNAction.repeatForever(floatSequence)
        companionModel?.runAction(repeatFloat)
        
        scene.rootNode.addChildNode(companionModel!)
        
        // Add enhanced lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = PlatformColor.white
        ambientLight.light?.intensity = 300
        scene.rootNode.addChildNode(ambientLight)
        
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.color = PlatformColor.white
        directionalLight.light?.intensity = 1000
        directionalLight.position = SCNVector3(5, 5, 5)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
        
        // Add camera with better positioning
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupAudio() {
        // Voice manager handles its own delegate setup
        // Setup lip-sync monitoring
        setupLipSync()
    }
    
    private func setupLipSync() {
        // Monitor voice manager for lip-sync updates
        lipSyncTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateLipSync()
        }
    }
    
    private func updateLipSync() {
        guard let companionModel = companionModel else { return }
        
        if voiceManager.isSpeaking {
            let mouthOpenness = voiceManager.getMouthOpenness()
            updateMouthShape(openness: mouthOpenness)
        }
    }
    
    private func updateMouthShape(openness: Float) {
        guard let companionModel = companionModel else { return }
        
        // Scale mouth based on phoneme intensity
        let scale = SCNVector3(1.0, 0.4 + (openness * 0.6), 0.2 + (openness * 0.3))
        companionModel.mouthNode.scale = scale
    }
    
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                // Handle permission result
            }
        }
    }
    
    func speakToCompanion() {
        print("🔍 CompanionManager.speakToCompanion() called")
        print("🔍 userInput: '\(userInput)'")
        print("🔍 userInput.isEmpty: \(userInput.isEmpty)")
        
        guard !userInput.isEmpty else { 
            print("❌ userInput is empty, returning")
            return 
        }
        
        print("✅ userInput is not empty, proceeding with AI generation")
        let currentInput = userInput  // Capture the input before clearing it
        userInput = ""  // Clear it immediately
        
        // Start thinking animation
        companionModel?.playThinkingAnimation()
        
        Task {
            let response = await generateCompanionResponse(to: currentInput)
            
            // Stop thinking animation and start speaking
            await companionModel?.stopThinking()
            speak(text: response)
        }
    }
    
    private func generateCompanionResponse(to input: String) async -> String {
        print("🔍 CompanionManager.generateCompanionResponse() called with input: '\(input)'")
        print("🔍 Input length: \(input.count)")
        
        // Check if orchestrator is ready, if not use simple fallback
        guard orchestrator.isReady else {
            print("❌ Orchestrator not ready, using simple fallback")
            return "Hello! I'm your AI companion. I'm still starting up, but I'm here to chat with you!"
        }
        
        // Use AI orchestrator with proper AI libraries
        let response = await orchestrator.generateResponse(to: input)
        print("🔍 CompanionManager.generateCompanionResponse() returning: '\(response)'")
        
        // Add a clear indicator of which AI is being used
        print("🤖 CURRENT AI PROVIDER: \(orchestrator.currentAIProvider)")
        print("🤖 AI READY STATUS: \(orchestrator.isReady)")
        
        return response
    }
    
    func speak(text: String) {
        // Use enhanced voice manager with emotion detection
        let emotion = detectEmotionFromText(text)
        voiceManager.speak(text: text, with: emotion)
        
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
        
        // Add speaking animation to 3D model
        animateSpeaking()
    }
    
    private func detectEmotionFromText(_ text: String) -> VoiceManager.VoiceEmotion {
        let lowercaseText = text.lowercased()
        
        if lowercaseText.contains("!") || lowercaseText.contains("amazing") || lowercaseText.contains("awesome") {
            return .excited
        } else if lowercaseText.contains("sorry") || lowercaseText.contains("sad") || lowercaseText.contains("unfortunately") {
            return .sad
        } else if lowercaseText.contains("really") || lowercaseText.contains("actually") || lowercaseText.contains("hmm") {
            return .sarcastic
        } else if lowercaseText.contains("but") || lowercaseText.contains("however") || lowercaseText.contains("interesting") {
            return .witty
        } else if lowercaseText.contains("...") || lowercaseText.contains("let me think") || lowercaseText.contains("well") {
            return .thinking
        } else {
            return .neutral
        }
    }
    
    private func animateSpeaking() {
        // Enhanced speaking animation with lip sync
        companionModel?.startSpeaking()
        
        // Add subtle head movement while speaking
        let headBob = SCNAction.sequence([
            SCNAction.rotateBy(x: 0.05, y: 0, z: 0, duration: 0.5),
            SCNAction.rotateBy(x: -0.05, y: 0, z: 0, duration: 0.5)
        ])
        let repeatHeadBob = SCNAction.repeatForever(headBob)
        companionModel?.runAction(repeatHeadBob, forKey: "headBob")
    }
    
    func stopSpeaking() {
        voiceManager.stopSpeaking()
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
        companionModel?.stopSpeaking()
        companionModel?.removeAction(forKey: "headBob")
    }
    
    func startListening() {
        guard !isListening else { return }
        
        DispatchQueue.main.async {
            self.isListening = true
        }
        
        #if canImport(UIKit)
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.userInput = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                self.stopListening()
            }
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        DispatchQueue.main.async {
            self.isListening = false
        }
    }
}

extension CompanionManager {
    // Monitor voice manager state changes
    func updateSpeakingState() {
        DispatchQueue.main.async {
            self.isSpeaking = self.voiceManager.isSpeaking
            if !self.isSpeaking {
                self.companionModel?.stopSpeaking()
                self.companionModel?.removeAction(forKey: "headBob")
            }
        }
    }
}
