import Foundation
import Combine

/// Turns raw press/release timing from the key button into dots, dashes,
/// decoded letters, and full decoded text — plus record & playback of a
/// tapped sequence, mirroring the physical card's behaviour.
final class MorseInputEngine: ObservableObject {

    @Published var currentPattern: String = ""      // in-progress letter, e.g. "-.."
    @Published var decodedText: String = ""          // full decoded output
    @Published var isPressed: Bool = false
    @Published var isRecording: Bool = false
    @Published private(set) var recordedSequence: [(down: Bool, duration: TimeInterval)] = []

    /// One Morse "unit" in seconds. A dot ≈ 1 unit, a dash ≈ 3 units.
    /// It adapts slightly to the user's own tapping speed for a more
    /// forgiving, personalized feel — just like the real trainer.
    private var unit: TimeInterval = 0.15

    private var pressStart: Date?
    private var releaseStart: Date?
    private var letterGapTimer: Timer?
    private var wordGapTimer: Timer?

    // MARK: - Key events

    func press() {
        guard !isPressed else { return }
        isPressed = true
        let now = Date()

        if isRecording, let releaseStart {
            recordedSequence.append((down: false, duration: now.timeIntervalSince(releaseStart)))
        }

        pressStart = now
        letterGapTimer?.invalidate()
        wordGapTimer?.invalidate()
    }

    func release() {
        guard isPressed, let start = pressStart else { return }
        isPressed = false
        let now = Date()
        let duration = now.timeIntervalSince(start)
        releaseStart = now

        if isRecording {
            recordedSequence.append((down: true, duration: duration))
        }

        // Dot vs dash: a press shorter than ~2.5 units is a dot.
        let symbol = duration < unit * 2.5 ? "." : "-"
        currentPattern += symbol

        // Gently adapt the unit toward the user's dot speed.
        if symbol == "." {
            unit = (unit * 0.7) + (duration * 0.3)
            unit = min(max(unit, 0.08), 0.35)
        }

        scheduleLetterGapTimer()
    }

    // MARK: - Gap detection (turns patterns into letters/words automatically)

    private func scheduleLetterGapTimer() {
        letterGapTimer?.invalidate()
        letterGapTimer = Timer.scheduledTimer(withTimeInterval: unit * 3.0, repeats: false) { [weak self] _ in
            self?.finalizeLetter()
        }
    }

    private func finalizeLetter() {
        guard !currentPattern.isEmpty else { return }
        decodedText += MorseCode.decode(currentPattern) ?? "?"
        currentPattern = ""

        wordGapTimer?.invalidate()
        wordGapTimer = Timer.scheduledTimer(withTimeInterval: unit * 4.0, repeats: false) { [weak self] _ in
            guard let self, !self.decodedText.hasSuffix(" ") else { return }
            self.decodedText += " "
        }
    }

    func reset() {
        currentPattern = ""
        decodedText = ""
        pressStart = nil
        releaseStart = nil
        letterGapTimer?.invalidate()
        wordGapTimer?.invalidate()
    }

    // MARK: - Record & playback

    func startRecording() {
        recordedSequence.removeAll()
        isRecording = true
    }

    func stopRecording() {
        isRecording = false
    }

    /// Replays the recorded key-down/key-up timeline, driving `tone` and `flash`
    /// callbacks at the right moments — exactly like pressing "Play" on the card.
    func playback(flash: @escaping (Bool) -> Void,
                  tone: @escaping (Bool) -> Void,
                  completion: @escaping () -> Void) {
        guard !recordedSequence.isEmpty else { completion(); return }

        var delay: TimeInterval = 0
        for event in recordedSequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                flash(event.down)
                tone(event.down)
            }
            delay += event.duration
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            flash(false)
            tone(false)
            completion()
        }
    }
}
