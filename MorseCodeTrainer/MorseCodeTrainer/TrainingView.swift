import SwiftUI

/// Training mode: instead of showing the whole chart, it walks the Morse
/// binary tree one symbol at a time. At every moment only the *current*
/// path and the *two* branches you can go to next (dot or dash) are shown —
/// nothing else — matching the reveal-as-you-tap effect from the card's demo.
struct TrainingView: View {
    @ObservedObject var settings: AppSettings
    @StateObject private var engine = MorseInputEngine()
    private let tone = ToneGenerator()

    @State private var soundEnabled = true
    @State private var lightEnabled = true
    @State private var showSettings = false
    @State private var justLockedLetter: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {

                breadcrumb

                Spacer(minLength: 0)

                branches

                Spacer(minLength: 0)

                Text(engine.decodedText.isEmpty ? "Start tapping…" : engine.decodedText)
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .frame(maxWidth: .infinity)

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
                .frame(width: 170, height: 170)

                controls
            }
            .padding()
            .navigationTitle("Training")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: settings)
            }
            .onChange(of: engine.decodedText) { oldValue, newValue in
                guard newValue.count > oldValue.count, let last = newValue.last, last != " " else { return }
                let letter = String(last)
                justLockedLetter = letter
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if justLockedLetter == letter { justLockedLetter = nil }
                }
            }
        }
    }

    // MARK: - Breadcrumb of the path taken so far

    private var breadcrumb: some View {
        VStack(spacing: 8) {
            Text("PATH")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                if engine.currentPattern.isEmpty {
                    Text("Root")
                        .font(.system(size: 22, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(engine.currentPattern.enumerated()), id: \.offset) { _, ch in
                        Text(ch == "." ? "•" : "−")
                            .font(.system(size: 26, weight: .heavy, design: .monospaced))
                            .frame(width: 30, height: 30)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Circle())
                            .foregroundStyle(.orange)
                    }
                }
            }
            .frame(minHeight: 34)

            if let liveLetter = MorseCode.decode(engine.currentPattern) {
                Text(liveLetter)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.55), value: engine.currentPattern)
            } else if let locked = justLockedLetter {
                Text(locked)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - The two next possible branches (this is the "not everything at once" part)

    private var branches: some View {
        HStack(spacing: 16) {
            branchCard(symbol: ".")
            branchCard(symbol: "-")
        }
    }

    private func branchCard(symbol: String) -> some View {
        let pattern = engine.currentPattern + symbol
        let letter = MorseCode.decode(pattern)
        let continues = MorseCode.hasContinuation(beyond: pattern)
        let reachable = MorseCode.isReachable(pattern)

        return VStack(spacing: 10) {
            Text(symbol == "." ? "DOT" : "DASH")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Text(symbol == "." ? "•" : "−")
                .font(.system(size: 34, weight: .heavy, design: .monospaced))
                .foregroundStyle(reachable ? .orange : .secondary)

            Group {
                if let letter {
                    Text(letter)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                } else if reachable {
                    Text("···")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("–")
                        .font(.title2)
                        .foregroundStyle(.secondary.opacity(0.4))
                }
            }
            .frame(height: 34)

            Text(continues ? "leads further" : (letter != nil ? "final letter" : " "))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(reachable ? 1 : 0.4)
        .animation(.easeOut(duration: 0.15), value: engine.currentPattern)
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
        }
        .font(.title3)
        .padding(.bottom, 4)
    }
}

#Preview {
    TrainingView(settings: AppSettings())
}
