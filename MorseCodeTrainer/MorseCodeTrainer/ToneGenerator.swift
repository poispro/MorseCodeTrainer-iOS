import AVFoundation

/// Generates a continuous 700 Hz sine tone (classic CW/Morse pitch) that can be
/// started/stopped instantly in sync with key presses, with no audio-file latency.
final class ToneGenerator {

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    private var currentPhase = 0.0
    private let sampleRate = 44_100.0
    private let frequency = 700.0
    private var isPlaying = false

    init() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let phaseIncrement = 2.0 * Double.pi * self.frequency / self.sampleRate
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                let sample: Float = self.isPlaying ? Float(sin(self.currentPhase)) * 0.25 : 0
                self.currentPhase += phaseIncrement
                if self.currentPhase > 2.0 * Double.pi { self.currentPhase -= 2.0 * Double.pi }
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }

        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            engine.prepare()
            try engine.start()
        } catch {
            print("ToneGenerator failed to start audio engine: \(error)")
        }
    }

    func start() { isPlaying = true }
    func stop() { isPlaying = false }
}
