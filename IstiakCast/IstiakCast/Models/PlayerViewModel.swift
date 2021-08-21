

import SwiftUI
import AVFoundation

class PlayerViewModel: NSObject, ObservableObject {
  // MARK: Public properties

  var isPlaying = false {
    willSet {
      withAnimation {
        objectWillChange.send()
      }
    }
  }
  var isPlayerReady = false {
    willSet {
      objectWillChange.send()
    }
  }
  var playbackRateIndex: Int = 1 {
    willSet {
      objectWillChange.send()
    }
    didSet {
      updateForRateSelection()
    }
  }
  var playbackPitchIndex: Int = 1 {
    willSet {
      objectWillChange.send()
    }
    didSet {
      updateForPitchSelection()
    }
  }
  var playerProgress: Double = 0 {
    willSet {
      objectWillChange.send()
    }
  }
  var playerTime: PlayerTime = .zero {
    willSet {
      objectWillChange.send()
    }
  }
  var meterLevel: Float = 0 {
    willSet {
      objectWillChange.send()
    }
  }

  let allPlaybackRates: [PlaybackValue] = [
    .init(value: 0.5, label: "0.5x"),
    .init(value: 1, label: "1x"),
    .init(value: 1.25, label: "1.25x"),
    .init(value: 2, label: "2x")
  ]

  let allPlaybackPitches: [PlaybackValue] = [
    .init(value: -0.5, label: "-½"),
    .init(value: 0, label: "0"),
    .init(value: 0.5, label: "+½")
  ]

  // MARK: Private properties

  private let engine = AVAudioEngine()
  private let player = AVAudioPlayerNode()
  private let timeEffect = AVAudioUnitTimePitch()

  private var displayLink: CADisplayLink?

  private var needsFileScheduled = true

  private var audioFile: AVAudioFile?
  private var audioSampleRate: Double = 0
  private var audioLengthSeconds: Double = 0

  private var seekFrame: AVAudioFramePosition = 0
  private var currentPosition: AVAudioFramePosition = 0
  private var audioSeekFrame: AVAudioFramePosition = 0
  private var audioLengthSamples: AVAudioFramePosition = 0

  private var currentFrame: AVAudioFramePosition {
    guard
      let lastRenderTime = player.lastRenderTime,
      let playerTime = player.playerTime(forNodeTime: lastRenderTime)
    else {
      return 0
    }

    return playerTime.sampleTime
  }

  // MARK: - Public

  override init() {
    super.init()

    setupAudio()
    setupDisplayLink()
  }

  func playOrPause() {
  }

  func skip(forwards: Bool) {
  }

  // MARK: - Private

  private func setupAudio() {
  }

  private func configureEngine(with format: AVAudioFormat) {
  }

  private func scheduleAudioFile() {
  }

  // MARK: Audio adjustments

  private func seek(to time: Double) {
  }

  private func updateForRateSelection() {
  }

  private func updateForPitchSelection() {
  }

  // MARK: Audio metering

  private func scaledPower(power: Float) -> Float {
    return 0
  }

  private func connectVolumeTap() {
  }

  private func disconnectVolumeTap() {
  }

  // MARK: Display updates

  private func setupDisplayLink() {
  }

  @objc private func updateDisplay() {
  }
}
