import SwiftUI
import AVFoundation
import UIKit
import Combine

final class ScratchFeedbackManager: ObservableObject {
    @Published var isSoundEnabled: Bool = true {
        didSet {
            if !isSoundEnabled {
                stopScratchSound()
            }
        }
    }
    @Published var isHapticsEnabled: Bool = true

    private let engine = AVAudioEngine()
    private let scratchNode = AVAudioPlayerNode()
    private let reverbNode = AVAudioUnitReverb()
    private let eqNode = AVAudioUnitEQ(numberOfBands: 2)
    private var scratchBuffer: AVAudioPCMBuffer?
    private var isScratchPlaying = false

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let successFeedback = UINotificationFeedbackGenerator()
    private var lastHapticTime: Date = .distantPast
    private let hapticThrottle: TimeInterval = 0.04

    init() {
        setupAudioEngine()
        lightImpact.prepare()
        mediumImpact.prepare()
        successFeedback.prepare()
    }

    private func setupAudioEngine() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true)

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { return }
        let frameCount = AVAudioFrameCount(44_100 * 0.25)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        if let data = buffer.floatChannelData?[0] {
            for i in 0..<Int(frameCount) {
                let t = Float(i) / Float(frameCount)
                let fade = min(t * 20, 1.0) * min((1 - t) * 20, 1.0)
                data[i] = Float.random(in: -1...1) * 0.15 * fade
            }
        }

        scratchBuffer = buffer

        eqNode.bands[0].filterType = .lowPass
        eqNode.bands[0].frequency = 2800
        eqNode.bands[0].bypass = false

        eqNode.bands[1].filterType = .parametric
        eqNode.bands[1].frequency = 700
        eqNode.bands[1].gain = 5
        eqNode.bands[1].bandwidth = 1.0
        eqNode.bands[1].bypass = false

        reverbNode.loadFactoryPreset(.smallRoom)
        reverbNode.wetDryMix = 18

        engine.attach(scratchNode)
        engine.attach(eqNode)
        engine.attach(reverbNode)
        engine.connect(scratchNode, to: eqNode, format: format)
        engine.connect(eqNode, to: reverbNode, format: format)
        engine.connect(reverbNode, to: engine.mainMixerNode, format: format)

        try? engine.start()
    }

    func startScratchSound() {
        guard isSoundEnabled, let buffer = scratchBuffer, !isScratchPlaying else { return }
        isScratchPlaying = true
        if !engine.isRunning {
            try? engine.start()
        }
        scratchNode.scheduleBuffer(buffer, at: nil, options: .loops)
        scratchNode.play()
    }

    func stopScratchSound() {
        guard isScratchPlaying else { return }
        isScratchPlaying = false
        scratchNode.stop()
    }

    func playWinSound() {
        guard isSoundEnabled else { return }
        stopScratchSound()

        let sampleRate = 44_100.0
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }

        let frequencies: [Double] = [523.25, 659.25, 783.99, 1046.50]
        let noteDuration = 0.13
        let totalFrames = AVAudioFrameCount(sampleRate * (noteDuration * Double(frequencies.count) + 0.5))

        guard let chime = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else { return }
        chime.frameLength = totalFrames

        if let data = chime.floatChannelData?[0] {
            for i in 0..<Int(totalFrames) {
                let t = Double(i) / sampleRate
                var sample: Float = 0

                for (index, freq) in frequencies.enumerated() {
                    let start = Double(index) * noteDuration
                    if t >= start {
                        let env = Float(exp(-(t - start) * (1.0 / (noteDuration * 3.0))))
                        sample += (Float(sin(2 * .pi * freq * t)) * 0.7 +
                                   Float(sin(2 * .pi * freq * 2.0 * t)) * 0.15) * env * 0.22
                    }
                }

                data[i] = max(-1, min(1, sample))
            }
        }

        let winNode = AVAudioPlayerNode()
        engine.attach(winNode)
        engine.connect(winNode, to: engine.mainMixerNode, format: format)

        if !engine.isRunning {
            try? engine.start()
        }

        winNode.scheduleBuffer(chime, at: nil) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard let self else { return }
                self.engine.detach(winNode)
            }
        }
        winNode.play()
    }

    func scratchHaptic() {
        guard isHapticsEnabled else { return }
        let now = Date()
        guard now.timeIntervalSince(lastHapticTime) >= hapticThrottle else { return }
        lastHapticTime = now
        lightImpact.impactOccurred(intensity: 0.45)
    }

    func winHaptic() {
        guard isHapticsEnabled else { return }
        successFeedback.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            self.mediumImpact.impactOccurred(intensity: 0.75)
        }
    }

    func tapHaptic() {
        guard isHapticsEnabled else { return }
        mediumImpact.impactOccurred()
    }
}
