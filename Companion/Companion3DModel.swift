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
    private var mouthNode: SCNNode
    private var eyeNodes: [SCNNode] = []
    
    // Animation properties
    private var isSpeaking: Bool = false
    private var mouthOpenness: Float = 0.0
    private var eyeBlinkTimer: Timer?
    
    override init() {
        // Create head (main body)
        let headGeometry = SCNSphere(radius: 1.0)
        headGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemBlue
        headGeometry.firstMaterial?.specular.contents = PlatformColor.white
        headGeometry.firstMaterial?.shininess = 0.1
        
        headNode = SCNNode(geometry: headGeometry)
        
        // Create mouth
        let mouthGeometry = SCNSphere(radius: 0.1)
        mouthGeometry.firstMaterial?.diffuse.contents = PlatformColor.systemPink
        mouthNode = SCNNode(geometry: mouthGeometry)
        mouthNode.position = SCNVector3(0, -0.3, 0.9)
        mouthNode.scale = SCNVector3(1.0, 0.3, 0.1)
        
        // Create eyes
        let eyeGeometry = SCNSphere(radius: 0.15)
        eyeGeometry.firstMaterial?.diffuse.contents = PlatformColor.white
        
        let leftEye = SCNNode(geometry: eyeGeometry)
        leftEye.position = SCNVector3(-0.3, 0.2, 0.8)
        
        let rightEye = SCNNode(geometry: eyeGeometry)
        rightEye.position = SCNVector3(0.3, 0.2, 0.8)
        
        // Create pupils
        let pupilGeometry = SCNSphere(radius: 0.08)
        pupilGeometry.firstMaterial?.diffuse.contents = PlatformColor.black
        
        let leftPupil = SCNNode(geometry: pupilGeometry)
        leftPupil.position = SCNVector3(0, 0, 0.1)
        leftEye.addChildNode(leftPupil)
        
        let rightPupil = SCNNode(geometry: pupilGeometry)
        rightPupil.position = SCNVector3(0, 0, 0.1)
        rightEye.addChildNode(rightPupil)
        
        super.init()
        
        // Assemble the character
        addChildNode(headNode)
        headNode.addChildNode(mouthNode)
        headNode.addChildNode(leftEye)
        headNode.addChildNode(rightEye)
        
        eyeNodes = [leftEye, rightEye]
        
        // Start blinking animation
        startBlinking()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Animation Methods
    
    func startSpeaking() {
        isSpeaking = true
        animateMouth()
    }
    
    func stopSpeaking() {
        isSpeaking = false
        mouthNode.scale = SCNVector3(1.0, 0.3, 0.1)
    }
    
    private func animateMouth() {
        guard isSpeaking else { return }
        
        let openMouth = SCNAction.scale(to: 1.2, duration: 0.1)
        let closeMouth = SCNAction.scale(to: 0.8, duration: 0.1)
        let mouthSequence = SCNAction.sequence([openMouth, closeMouth])
        let repeatMouth = SCNAction.repeatForever(mouthSequence)
        
        mouthNode.runAction(repeatMouth, forKey: "mouthAnimation")
    }
    
    private func startBlinking() {
        eyeBlinkTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2.0...4.0), repeats: true) { _ in
            self.blink()
        }
    }
    
    private func blink() {
        let blinkGeometry = SCNSphere(radius: 0.15)
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
    
    deinit {
        eyeBlinkTimer?.invalidate()
    }
}
