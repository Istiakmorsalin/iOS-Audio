

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
    // This gets the URL of the audio file included in the app bundle
    guard let fileURL = Bundle.main.url(
      forResource: "Topu",
      withExtension: "mp3")
    else {
      return
    }

    do {
      // The audio file is transformed into an AVAudioFile and a few properties are extracted from the file’s metadata
      let file = try AVAudioFile(forReading: fileURL)
      let format = file.processingFormat
      
      audioLengthSamples = file.length
      audioSampleRate = format.sampleRate
      audioLengthSeconds = Double(audioLengthSamples) / audioSampleRate
      
      audioFile = file
      
      // prepare an audio file for playback is to set up the audio engine
      configureEngine(with: format)
    } catch {
      print("Error reading the audio file: \(error.localizedDescription)")
    }
  }

  private func configureEngine(with format: AVAudioFormat) {
    // Attach the player node to the engine
    engine.attach(player)
    engine.attach(timeEffect)

    // Connect the player and time effect to the engine
    engine.connect(
      player,
      to: timeEffect,
      format: format)
    engine.connect(
      timeEffect,
      to: engine.mainMixerNode,
      format: format)

    engine.prepare()

    do {
      // Start the engine, which prepares the device to play audio. The state is also updated to prepare the visual interface.
      try engine.start()
      
      scheduleAudioFile()
      isPlayerReady = true
    } catch {
      print("Error starting the player: \(error.localizedDescription)")
    }

  }

  private func scheduleAudioFile() {
    guard
      let file = audioFile,
      needsFileScheduled
    else {
      return
    }

    needsFileScheduled = false
    seekFrame = 0

    player.scheduleFile(file, at: nil) {
      self.needsFileScheduled = true
    }

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
