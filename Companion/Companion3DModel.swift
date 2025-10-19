import Foundation
import SceneKit
import AVFoundation
import Combine
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

class Companion3DModel: SCNNode {
    private var modelNode: SCNNode?
    var mouthNode: SCNNode?
    private var eyeNodes: [SCNNode] = []
    private var eyebrowNodes: [SCNNode] = []
    private var particleSystem: SCNParticleSystem?
    private var thinkingParticles: SCNNode?
    
    // Loading state management
    @Published var isLoading: Bool = true
    @Published var loadingProgress: Float = 0.0
    private var isModelLoaded: Bool = false
    
    // Animation properties
    private var isSpeaking: Bool = false
    private var isThinking: Bool = false
    private var mouthOpenness: Float = 0.0
    private var eyeBlinkTimer: Timer?
    private var breathingTimer: Timer?
    private var currentEmotion: Emotion = .neutral
    
    enum Emotion {
        case neutral, happy, sad, excited, thinking, confused
    }
    
    override init() {
        super.init()
        
        // Start with lightweight fallback geometry for immediate display
        createFallbackGeometry()
        
        // Load USDZ model asynchronously in background
        Task {
            await loadUSDZModelAsync()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - USDZ Model Loading
    
    private func loadUSDZModelAsync() async {
        print("🚀 Starting async USDZ model loading...")
        
        // Update loading progress
        await MainActor.run {
            self.loadingProgress = 0.1
        }
        
        // Check if model exists
        guard let url = Bundle.main.url(forResource: "maddie", withExtension: "usdz") else {
            print("❌ USDZ model not found in bundle")
            await MainActor.run {
                self.isLoading = false
            }
            return
        }
        
        await MainActor.run {
            self.loadingProgress = 0.3
        }
        
        // Load model on background queue
        do {
            let scene = try await Task.detached {
                try SCNScene(url: url)
            }.value
            
            await MainActor.run {
                self.loadingProgress = 0.7
            }
            
            // Update UI on main thread
            await MainActor.run {
                // Remove fallback geometry
                self.removeAllChildNodes()
                
                // Add the new model
                self.modelNode = scene.rootNode
                if let modelNode = self.modelNode {
                    self.addChildNode(modelNode)
                    self.findFacialNodes()
                }
                
                self.isModelLoaded = true
                self.isLoading = false
                self.loadingProgress = 1.0
                
                // Setup animations now that model is loaded
                self.setupAnimations()
                self.setupParticleSystem()
                self.startBreathing()
                
                print("✅ USDZ model loaded successfully asynchronously!")
            }
        } catch {
            print("❌ Failed to load USDZ model asynchronously: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func removeAllChildNodes() {
        // Remove all existing child nodes
        for child in childNodes {
            child.removeFromParentNode()
        }
    }
    
    private func findFacialNodes() {
        // Search for common facial node names in the USDZ model
        let mouthNames = ["mouth", "Mouth", "jaw", "Jaw", "lower_jaw", "Lower_Jaw"]
        let eyeNames = ["eye", "Eye", "eyes", "Eyes", "eyeball", "Eyeball"]
        
        // Find mouth node
        for name in mouthNames {
            if let node = modelNode?.childNode(withName: name, recursively: true) {
                mouthNode = node
                print("✅ Found mouth node: \(name)")
                break
            }
        }
        
        // Find eye nodes
        for name in eyeNames {
            if let node = modelNode?.childNode(withName: name, recursively: true) {
                eyeNodes.append(node)
                print("✅ Found eye node: \(name)")
            }
        }
    }
    
    private func createFallbackGeometry() {
        // Create lightweight fallback geometry for immediate display
        let headGeometry = SCNSphere(radius: 1.0)
        headGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBlue.withAlphaComponent(0.9)
        headGeometry.firstMaterial?.specular.contents = PlatformColor.white
        headGeometry.firstMaterial?.shininess = 0.3
        
        let headNode = SCNNode(geometry: headGeometry)
        headNode.name = "fallback_head"
        
        // Create simple body
        let bodyGeometry = SCNSphere(radius: 0.6)
        bodyGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemPurple.withAlphaComponent(0.8)
        bodyGeometry.firstMaterial?.specular.contents = PlatformColor.white
        bodyGeometry.firstMaterial?.shininess = 0.2
        
        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, -1.2, 0)
        bodyNode.scale = SCNVector3(0.8, 1.2, 0.6)
        bodyNode.name = "fallback_body"
        
        // Create simple mouth for fallback
        let mouthGeometry = SCNSphere(radius: 0.1)
        mouthGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemPink
        mouthNode = SCNNode(geometry: mouthGeometry)
        mouthNode?.position = SCNVector3(0, -0.2, 0.8)
        mouthNode?.name = "fallback_mouth"
        
        // Add fallback nodes
        addChildNode(headNode)
        addChildNode(bodyNode)
        if let mouthNode = mouthNode {
            addChildNode(mouthNode)
        }
        
        print("✅ Created lightweight fallback geometry for instant display")
    }
    
    // MARK: - Animation Setup
    
    private func setupAnimations() {
        // Setup animation timers and initial states
        startBlinking()
    }
    
    private func setupParticleSystem() {
        // Disable particle system to avoid Metal texture issues
        // TODO: Re-enable with proper texture handling
        self.particleSystem = nil
        thinkingParticles = nil
    }
    
    // MARK: - Animation Methods
    
    func startSpeaking() {
        isSpeaking = true
        setEmotion(.excited)
        // TODO: Implement mouth animation based on USDZ model rigging
    }
    
    func stopSpeaking() {
        isSpeaking = false
        setEmotion(.neutral)
        // TODO: Reset mouth to neutral position
    }
    
    func startThinking() {
        isThinking = true
        setEmotion(.thinking)
        // TODO: Implement thinking animation
    }
    
    func stopThinking() {
        isThinking = false
        setEmotion(.neutral)
        // TODO: Stop thinking animation
    }
    
    func updateMouthShape(openness: Float) {
        mouthOpenness = openness
        // TODO: Update mouth shape based on USDZ model rigging
        // This would typically involve animating bone transforms or morph targets
    }
    
    // MARK: - Emotion System
    
    func setEmotion(_ emotion: Emotion) {
        currentEmotion = emotion
        updateFacialExpression(for: emotion)
    }
    
    private func updateFacialExpression(for emotion: Emotion) {
        // TODO: Implement facial expression changes based on USDZ model
        // This would involve animating facial bones or morph targets
        switch emotion {
        case .neutral:
            // Reset to neutral expression
            break
        case .happy:
            // Animate to happy expression
            break
        case .sad:
            // Animate to sad expression
            break
        case .excited:
            // Animate to excited expression
            break
        case .thinking:
            // Animate to thinking expression
            break
        case .confused:
            // Animate to confused expression
            break
        }
    }
    
    // MARK: - Idle Animations
    
    private func startBreathing() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.animateBreathing()
        }
    }
    
    private func animateBreathing() {
        // TODO: Implement breathing animation using USDZ model
        // This would involve subtle chest/body movement
    }
    
    private func startBlinking() {
        eyeBlinkTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2.0...5.0), repeats: true) { [weak self] _ in
            self?.animateBlink()
        }
    }
    
    private func animateBlink() {
        // TODO: Implement blinking animation using USDZ model
        // This would involve eyelid movement
    }
    
    // MARK: - Public Animation Controls
    
    func playIdleAnimation() {
        // TODO: Implement idle animation sequence
    }
    
    func playThinkingAnimation() {
        startThinking()
    }
    
    func playSpeakingAnimation() {
        startSpeaking()
    }
    
    func stopAllAnimations() {
        stopSpeaking()
        stopThinking()
    }
    
    deinit {
        eyeBlinkTimer?.invalidate()
        breathingTimer?.invalidate()
    }
}
