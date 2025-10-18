import SwiftUI
import SceneKit
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

@main
struct CompanionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var companionManager = CompanionManager()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 3D Model View
                Companion3DView(companionManager: companionManager)
                    .frame(height: 400)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                // Enhanced status indicator
                VStack(spacing: 8) {
                    HStack {
                        if companionManager.isSpeaking {
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(companionManager.isSpeaking ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: companionManager.isSpeaking)
                                Text("Maddie is speaking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else if companionManager.isListening {
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(companionManager.isListening ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: companionManager.isListening)
                                Text("Listening...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            HStack {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 8, height: 8)
                                Text("Maddie is ready")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Personality indicator
                    HStack {
                        Text("🤖")
                            .font(.caption)
                        Text("Witty • Edgy • Uncensored")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                // Enhanced controls
                VStack(spacing: 20) {
                    // Input field with better styling
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ask Maddie anything...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Type your message...", text: $companionManager.userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                companionManager.speakToCompanion()
                            }
                    }
                    
                    // Control buttons with enhanced styling
                    HStack(spacing: 15) {
                        Button(action: {
                            companionManager.speakToCompanion()
                        }) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                Text("Speak to Maddie")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                        }
                        .disabled(companionManager.userInput.isEmpty)
                        
                        Button(action: {
                            if companionManager.isListening {
                                companionManager.stopListening()
                            } else {
                                companionManager.startListening()
                            }
                        }) {
                            HStack {
                                Image(systemName: companionManager.isListening ? "mic.fill" : "mic")
                                Text(companionManager.isListening ? "Stop Listening" : "Voice Input")
                            }
                            .foregroundColor(companionManager.isListening ? .white : .blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                companionManager.isListening ? 
                                Color.red : 
                                Color.blue.opacity(0.1)
                            )
                            .cornerRadius(20)
                        }
                        
                        Button(action: {
                            companionManager.stopSpeaking()
                        }) {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                Text("Stop")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .cornerRadius(20)
                        }
                        .disabled(!companionManager.isSpeaking)
                    }
                    
                    // Feature highlights
                    VStack(spacing: 8) {
                        Text("✨ Enhanced Features")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("🎭")
                                    .font(.title2)
                                Text("3D Animations")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("🎤")
                                    .font(.title2)
                                Text("Voice Synthesis")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("🧠")
                                    .font(.title2)
                                Text("Maddie Personality")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("💬")
                                    .font(.title2)
                                Text("Uncensored Chat")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
                .navigationTitle("🤖 Maddie Companion")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                #if canImport(UIKit)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

#if canImport(UIKit)
struct Companion3DView: UIViewRepresentable {
    let companionManager: CompanionManager
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = companionManager.scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.systemBackground
        sceneView.antialiasingMode = .multisampling4X
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the 3D view when needed
    }
}
#else
struct Companion3DView: NSViewRepresentable {
    let companionManager: CompanionManager
    
    func makeNSView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = companionManager.scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = NSColor.controlBackgroundColor
        sceneView.antialiasingMode = .multisampling4X
        return sceneView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // Update the 3D view when needed
    }
}
#endif

struct SettingsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("speechRate") private var speechRate: Double = 0.3
    @AppStorage("speechPitch") private var speechPitch: Double = 1.0
    @AppStorage("companionName") private var companionName: String = "Companion"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Companion Settings") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Companion", text: $companionName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 120)
                    }
                }
                
                Section("Speech Settings") {
                    VStack(alignment: .leading) {
                        Text("Speech Rate: \(speechRate, specifier: "%.1f")")
                        Slider(value: $speechRate, in: 0.1...1.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Speech Pitch: \(speechPitch, specifier: "%.1f")")
                        Slider(value: $speechPitch, in: 0.5...2.0, step: 0.1)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Companion AI")
                        Spacer()
                        Text("Powered by SwiftUI & SceneKit")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if canImport(UIKit)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                #endif
            }
        }
    }
}

#Preview {
    ContentView()
}
