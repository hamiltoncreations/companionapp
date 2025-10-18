import Foundation
import SceneKit
import AVFoundation
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif


class Companion3DModel: SCNNode {
    private var headNode: SCNNode
    private var bodyNode: SCNNode
    var mouthNode: SCNNode
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
        // Create main head with improved geometry
        let headGeometry = SCNSphere(radius: 1.2)
        headNode = SCNNode(geometry: headGeometry)
        
        // Create body structure
        let bodyGeometry = SCNSphere(radius: 0.8)
        bodyGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBlue.withAlphaComponent(0.8)
        bodyGeometry.firstMaterial?.specular.contents = PlatformColor.white
        bodyGeometry.firstMaterial?.shininess = 0.2
        
        bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, -1.5, 0)
        bodyNode.scale = SCNVector3(0.7, 1.0, 0.6)
        
        // Create enhanced mouth with better geometry
        let mouthGeometry = SCNCapsule(capRadius: 0.15, height: 0.3)
        mouthGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemPink
        mouthGeometry.firstMaterial?.specular.contents = PlatformColor.white
        mouthGeometry.firstMaterial?.shininess = 0.8
        
        mouthNode = SCNNode(geometry: mouthGeometry)
        mouthNode.position = SCNVector3(0, -0.4, 0.95)
        mouthNode.scale = SCNVector3(1.0, 0.4, 0.2)
        
        // Create enhanced eyes with better structure
        let eyeGeometry = SCNSphere(radius: 0.18)
        eyeGeometry.firstMaterial?.diffuse.contents = PlatformColor.white
        eyeGeometry.firstMaterial?.specular.contents = PlatformColor.white
        eyeGeometry.firstMaterial?.shininess = 0.9
        
        let leftEye = SCNNode(geometry: eyeGeometry)
        leftEye.position = SCNVector3(-0.35, 0.25, 0.85)
        
        let rightEye = SCNNode(geometry: eyeGeometry)
        rightEye.position = SCNVector3(0.35, 0.25, 0.85)
        
        // Create pupils with better positioning
        let pupilGeometry = SCNSphere(radius: 0.1)
        pupilGeometry.firstMaterial?.diffuse.contents = PlatformColor.black
        pupilGeometry.firstMaterial?.specular.contents = PlatformColor.white
        pupilGeometry.firstMaterial?.shininess = 1.0
        
        let leftPupil = SCNNode(geometry: pupilGeometry)
        leftPupil.position = SCNVector3(0, 0, 0.12)
        leftEye.addChildNode(leftPupil)
        
        let rightPupil = SCNNode(geometry: pupilGeometry)
        rightPupil.position = SCNVector3(0, 0, 0.12)
        rightEye.addChildNode(rightPupil)
        
        // Create eyebrows for expression
        let eyebrowGeometry = SCNCapsule(capRadius: 0.05, height: 0.3)
        eyebrowGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBrown
        
        let leftEyebrow = SCNNode(geometry: eyebrowGeometry)
        leftEyebrow.position = SCNVector3(-0.3, 0.5, 0.7)
        leftEyebrow.rotation = SCNVector4(0, 0, 1, 0.2)
        
        let rightEyebrow = SCNNode(geometry: eyebrowGeometry)
        rightEyebrow.position = SCNVector3(0.3, 0.5, 0.7)
        rightEyebrow.rotation = SCNVector4(0, 0, 1, -0.2)
        
        super.init()
        
        // Assemble the enhanced character
        addChildNode(headNode)
        addChildNode(bodyNode)
        headNode.addChildNode(mouthNode)
        headNode.addChildNode(leftEye)
        headNode.addChildNode(rightEye)
        headNode.addChildNode(leftEyebrow)
        headNode.addChildNode(rightEyebrow)
        
        eyeNodes = [leftEye, rightEye]
        eyebrowNodes = [leftEyebrow, rightEyebrow]
        
        // Setup particle system for thinking state
        setupParticleSystem()
        
        // Setup materials after super.init()
        if let headGeometry = headNode.geometry {
            headGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBlue
            headGeometry.firstMaterial?.specular.contents = PlatformColor.white
            headGeometry.firstMaterial?.shininess = 0.3
            // Disable normal map to avoid Metal texture issues
            // headGeometry.firstMaterial?.normal.contents = createNormalMap()
        }
        
        // Start animations
        startBlinking()
        startBreathing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Material Creation Methods
    
    private func createGradientMaterial() -> Any {
        // Use simple solid color instead of gradient to avoid Metal texture issues
        return PlatformColor.systemBlue
    }
    
    private func createNormalMap() -> Any {
        // Use a simple solid color instead of complex texture generation
        #if canImport(UIKit)
        return PlatformColor.blue
        #else
        return PlatformColor.blue
        #endif
    }
    
    private func setupParticleSystem() {
        // Disable particle system to avoid Metal texture issues
        // TODO: Re-enable with proper texture handling
        self.particleSystem = nil
        thinkingParticles = nil
    }
    
    private func createParticleImage() -> Any {
        // Use a simple solid color instead of complex image generation
        #if canImport(UIKit)
        return PlatformColor.white
        #else
        return PlatformColor.white
        #endif
    }
    
    // MARK: - Animation Methods
    
    func startSpeaking() {
        isSpeaking = true
        animateMouth()
        setEmotion(.excited)
    }
    
    func stopSpeaking() {
        isSpeaking = false
        mouthNode.scale = SCNVector3(1.0, 0.4, 0.2)
        setEmotion(.neutral)
    }
    
    func startThinking() {
        isThinking = true
        // thinkingParticles?.isHidden = false  // Disabled to avoid Metal issues
        setEmotion(.thinking)
        animateThinking()
    }
    
    func stopThinking() {
        isThinking = false
        // thinkingParticles?.isHidden = true  // Disabled to avoid Metal issues
        setEmotion(.neutral)
    }
    
    private func animateMouth() {
        guard isSpeaking else { return }
        
        let openMouth = SCNAction.scale(to: 1.3, duration: 0.15)
        let closeMouth = SCNAction.scale(to: 0.7, duration: 0.15)
        let mouthSequence = SCNAction.sequence([openMouth, closeMouth])
        let repeatMouth = SCNAction.repeatForever(mouthSequence)
        
        mouthNode.runAction(repeatMouth, forKey: "mouthAnimation")
    }
    
    private func animateThinking() {
        guard isThinking else { return }
        
        let thinkUp = SCNAction.moveBy(x: 0, y: 0.1, z: 0, duration: 1.0)
        let thinkDown = SCNAction.moveBy(x: 0, y: -0.1, z: 0, duration: 1.0)
        let thinkSequence = SCNAction.sequence([thinkUp, thinkDown])
        let repeatThink = SCNAction.repeatForever(thinkSequence)
        
        headNode.runAction(repeatThink, forKey: "thinkingAnimation")
    }
    
    private func startBreathing() {
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.animateBreathing()
        }
    }
    
    private func animateBreathing() {
        let breatheIn = SCNAction.scale(to: 1.05, duration: 1.5)
        let breatheOut = SCNAction.scale(to: 1.0, duration: 1.5)
        let breatheSequence = SCNAction.sequence([breatheIn, breatheOut])
        
        headNode.runAction(breatheSequence, forKey: "breathing")
    }
    
    private func startBlinking() {
        eyeBlinkTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2.0...4.0), repeats: true) { _ in
            self.blink()
        }
    }
    
    private func blink() {
        let blinkGeometry = SCNSphere(radius: 0.18)
        blinkGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBlue
        
        for eye in eyeNodes {
            let blinkNode = SCNNode(geometry: blinkGeometry)
            blinkNode.position = SCNVector3(0, 0, 0.1)
            eye.addChildNode(blinkNode)
            
            let blinkAction = SCNAction.sequence([
                SCNAction.scale(to: 0.1, duration: 0.1),
                SCNAction.scale(to: 1.0, duration: 0.1),
                SCNAction.removeFromParentNode()
            ])
            
            blinkNode.runAction(blinkAction)
        }
    }
    
    // MARK: - Emotion System
    
    func setEmotion(_ emotion: Emotion) {
        currentEmotion = emotion
        updateFacialExpression(for: emotion)
    }
    
    private func updateFacialExpression(for emotion: Emotion) {
        // Stop any existing emotion animations
        eyebrowNodes.forEach { $0.removeAllActions() }
        eyeNodes.forEach { $0.removeAllActions() }
        
        switch emotion {
        case .neutral:
            resetToNeutral()
        case .happy:
            animateHappy()
        case .sad:
            animateSad()
        case .excited:
            animateExcited()
        case .thinking:
            animateThinking()
        case .confused:
            animateConfused()
        }
    }
    
    private func resetToNeutral() {
        // Reset eyebrows to neutral position
        for eyebrow in eyebrowNodes {
            eyebrow.runAction(SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.3))
        }
        
        // Reset eye scale
        for eye in eyeNodes {
            eye.runAction(SCNAction.scale(to: 1.0, duration: 0.3))
        }
    }
    
    private func animateHappy() {
        // Raise eyebrows slightly
        for eyebrow in eyebrowNodes {
            eyebrow.runAction(SCNAction.rotateBy(x: 0, y: 0, z: 0.1, duration: 0.3))
        }
        
        // Slightly squint eyes
        for eye in eyeNodes {
            eye.runAction(SCNAction.scale(to: 0.9, duration: 0.3))
        }
    }
    
    private func animateSad() {
        // Lower eyebrows
        for eyebrow in eyebrowNodes {
            eyebrow.runAction(SCNAction.rotateBy(x: 0, y: 0, z: -0.1, duration: 0.3))
        }
        
        // Slightly close eyes
        for eye in eyeNodes {
            eye.runAction(SCNAction.scale(to: 0.8, duration: 0.3))
        }
    }
    
    private func animateExcited() {
        // Raise eyebrows more
        for eyebrow in eyebrowNodes {
            eyebrow.runAction(SCNAction.rotateBy(x: 0, y: 0, z: 0.2, duration: 0.3))
        }
        
        // Widen eyes
        for eye in eyeNodes {
            eye.runAction(SCNAction.scale(to: 1.1, duration: 0.3))
        }
    }
    
    private func animateConfused() {
        // Asymmetric eyebrow movement
        if eyebrowNodes.count >= 2 {
            eyebrowNodes[0].runAction(SCNAction.rotateBy(x: 0, y: 0, z: 0.1, duration: 0.3))
            eyebrowNodes[1].runAction(SCNAction.rotateBy(x: 0, y: 0, z: -0.1, duration: 0.3))
        }
    }
    
    override func look(at position: SCNVector3) {
        let lookAtAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5)
        headNode.runAction(lookAtAction)
    }
    
    func nod() {
        let nodDown = SCNAction.rotateBy(x: CGFloat.pi * 0.1, y: 0, z: 0, duration: 0.2)
        let nodUp = SCNAction.rotateBy(x: -CGFloat.pi * 0.1, y: 0, z: 0, duration: 0.2)
        let nodSequence = SCNAction.sequence([nodDown, nodUp])
        
        headNode.runAction(nodSequence)
    }
    
    func shakeHead() {
        let shakeLeft = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 0.1, z: 0, duration: 0.1)
        let shakeRight = SCNAction.rotateBy(x: 0, y: -CGFloat.pi * 0.1, z: 0, duration: 0.1)
        let shakeSequence = SCNAction.sequence([shakeLeft, shakeRight, shakeLeft, shakeRight])
        
        headNode.runAction(shakeSequence)
    }
    
    // MARK: - Public Animation Controls
    
    func playIdleAnimation() {
        setEmotion(.neutral)
        startBreathing()
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
        headNode.removeAllActions()
        mouthNode.removeAllActions()
        eyeNodes.forEach { $0.removeAllActions() }
        eyebrowNodes.forEach { $0.removeAllActions() }
    }
    
    deinit {
        eyeBlinkTimer?.invalidate()
        breathingTimer?.invalidate()
    }
}
