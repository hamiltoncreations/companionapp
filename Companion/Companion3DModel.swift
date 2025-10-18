import Foundation
import SceneKit
import AVFoundation
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
        
        // Load USDZ model
        loadUSDZModel()
        
        // Create fallback geometry if USDZ loading fails
        if modelNode == nil {
            print("⚠️ USDZ model failed to load, using fallback geometry")
            createFallbackGeometry()
        } else {
            print("✅ USDZ model loaded successfully!")
        }
        
        // Setup animations and effects
        setupAnimations()
        setupParticleSystem()
        startBreathing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - USDZ Model Loading
    
    private func loadUSDZModel() {
        // Debug: List all files in bundle
        if let bundlePath = Bundle.main.resourcePath {
            print("📁 Bundle contents:")
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                for file in files {
                    if file.contains("maddie") || file.contains("usdz") {
                        print("  📄 Found: \(file)")
                    }
                }
            } catch {
                print("❌ Error listing bundle contents: \(error)")
            }
        }
        
        guard let url = Bundle.main.url(forResource: "maddie", withExtension: "usdz") else {
            print("❌ USDZ model not found in bundle")
            print("🔍 Searching for any .usdz files...")
            
            // Try to find any USDZ files
            if let bundlePath = Bundle.main.resourcePath {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: bundlePath)
                    let usdzFiles = files.filter { $0.hasSuffix(".usdz") }
                    print("📄 Found USDZ files: \(usdzFiles)")
                } catch {
                    print("❌ Error searching for USDZ files: \(error)")
                }
            }
            return
        }
        
        do {
            let scene = try SCNScene(url: url)
            modelNode = scene.rootNode
            
            // Add the model to our node
            if let modelNode = modelNode {
                addChildNode(modelNode)
                
                // Try to find mouth and eye nodes in the model
                findFacialNodes()
                
                print("✅ USDZ model loaded successfully")
            }
        } catch {
            print("❌ Failed to load USDZ model: \(error)")
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
        // Create fallback geometry if USDZ loading fails
        let headGeometry = SCNSphere(radius: 1.2)
        let headNode = SCNNode(geometry: headGeometry)
        
        // Create body structure
        let bodyGeometry = SCNSphere(radius: 0.8)
        bodyGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBlue.withAlphaComponent(0.8)
        bodyGeometry.firstMaterial?.specular.contents = PlatformColor.white
        bodyGeometry.firstMaterial?.shininess = 0.2
        
        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, -1.5, 0)
        bodyNode.scale = SCNVector3(0.7, 1.0, 0.6)
        
        // Create mouth for fallback
        let mouthGeometry = SCNCapsule(capRadius: 0.15, height: 0.3)
        mouthGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemPink
        mouthNode = SCNNode(geometry: mouthGeometry)
        mouthNode?.position = SCNVector3(0, -0.3, 0.9)
        
        // Add fallback nodes
        addChildNode(headNode)
        addChildNode(bodyNode)
        if let mouthNode = mouthNode {
            addChildNode(mouthNode)
        }
        
        print("⚠️ Using fallback geometry - USDZ model not available")
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
