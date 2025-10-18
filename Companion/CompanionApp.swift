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
                
                // Status indicator
                HStack {
                    if companionManager.isSpeaking {
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                                .scaleEffect(companionManager.isSpeaking ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(), value: companionManager.isSpeaking)
                            Text("Speaking...")
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
                                .fill(Color.gray)
                                .frame(width: 8, height: 8)
                            Text("Ready")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Controls
                VStack(spacing: 15) {
                    TextField("Type your message...", text: $companionManager.userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            companionManager.speakToCompanion()
                        }
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            companionManager.speakToCompanion()
                        }) {
                            HStack {
                                Image(systemName: "speaker.wave.2")
                                Text("Speak")
                            }
                        }
                        .buttonStyle(.borderedProminent)
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
                                Text(companionManager.isListening ? "Stop" : "Listen")
                            }
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(companionManager.isListening ? .red : .blue)
                        
                        Button(action: {
                            companionManager.stopSpeaking()
                        }) {
                            HStack {
                                Image(systemName: "stop.circle")
                                Text("Stop")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(!companionManager.isSpeaking)
                    }
                }
                .padding()
            }
            .padding()
            .navigationTitle("Companion")
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
    @AppStorage("speechRate") private var speechRate: Double = 0.5
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
