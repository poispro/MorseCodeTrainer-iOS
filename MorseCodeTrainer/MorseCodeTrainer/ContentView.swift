import SwiftUI

struct ContentView: View {
    @ObservedObject var settings: AppSettings
    @StateObject private var engine = MorseInputEngine()
    private let tone = ToneGenerator()

    @State private var soundEnabled = true
    @State private var lightEnabled = true
    @State private var showChart = false
    @State private var showSettings = false
    @State private var isPlayingBack = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Decoded text
                VStack(alignment: .leading, spacing: 6) {
                    Text("DECODED")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    ScrollView {
                        Text(engine.decodedText.isEmpty ? "—" : engine.decodedText)
                            .font(.system(size: 26, weight: .semibold, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 90)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Live in-progress pattern
                Text(engine.currentPattern.isEmpty ? " " : engine.currentPattern)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(.orange)
                    .frame(height: 36)

                Spacer(minLength: 0)

                MorseKeyButton(isPressed: engine.isPressed) { pressing in
                    if pressing {
                        engine.press()
                        if soundEnabled { tone.start() }
                        if lightEnabled { TorchController.setTorch(on: true) }
                    } else {
                        engine.release()
                        tone.stop()
                        TorchController.setTorch(on: false)
                    }
                }
                .frame(width: 220, height: 220)

                Spacer(minLength: 0)

                controls
            }
            .padding()
            .navigationTitle("Morse Trainer")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showChart = true
                    } label: {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
            }
            .sheet(isPresented: $showChart) {
                MorseChartView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: settings)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 22) {
            Toggle(isOn: $soundEnabled) {
                Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
            }
            .toggleStyle(.button)

            Toggle(isOn: $lightEnabled) {
                Image(systemName: lightEnabled ? "flashlight.on.fill" : "flashlight.off.fill")
            }
            .toggleStyle(.button)

            Button { engine.reset() } label: {
                Image(systemName: "arrow.counterclockwise")
            }

            Button {
                engine.isRecording ? engine.stopRecording() : engine.startRecording()
            } label: {
                Image(systemName: engine.isRecording ? "record.circle.fill" : "record.circle")
                    .foregroundStyle(engine.isRecording ? .red : .primary)
            }

            Button { playback() } label: {
                Image(systemName: "play.circle")
            }
            .disabled(engine.recordedSequence.isEmpty || isPlayingBack)
        }
        .font(.title2)
        .padding(.bottom, 8)
    }

    private func playback() {
        isPlayingBack = true
        engine.playback(
            flash: { on in if lightEnabled { TorchController.setTorch(on: on) } },
            tone: { on in if soundEnabled { on ? tone.start() : tone.stop() } },
            completion: { isPlayingBack = false }
        )
    }
}

/// The big press-and-hold key, styled after the PCB/gold-contact look of the card.
struct MorseKeyButton: View {
    let isPressed: Bool
    let onChange: (Bool) -> Void

    var body: some View {
        Circle()
            .fill(isPressed ? Color.orange : Color(.systemGray5))
            .overlay(Circle().stroke(Color.orange, lineWidth: 3))
            .overlay(
                Text(isPressed ? "•" : "TAP")
                    .font(.headline)
                    .foregroundStyle(isPressed ? .white : .primary)
            )
            .shadow(radius: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.08), value: isPressed)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !isPressed { onChange(true) } }
                    .onEnded { _ in onChange(false) }
            )
            .accessibilityLabel("Morse key")
            .accessibilityAddTraits(.isButton)
    }
}

/// Reference chart, equivalent to the printed alphabet on the front of the card.
struct MorseChartView: View {
    @Environment(\.dismiss) private var dismiss
    private let columns = [GridItem(.adaptive(minimum: 72))]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(MorseCode.alphabet, id: \.0) { pair in
                        VStack(spacing: 4) {
                            Text(pair.0).font(.title3.bold())
                            Text(pair.1)
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.orange)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .navigationTitle("Morse Chart")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ContentView(settings: AppSettings())
}
