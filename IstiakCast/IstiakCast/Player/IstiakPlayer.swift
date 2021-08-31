//
//  IstiakPlayer.swift
//  IstiakCast
//
//  Created by ISTIAK on 29/8/21.
//

import UIKit
import MediaPlayer
import Kingfisher
import AVFoundation

class IstiakPlayer: NSObject {
    
    private var worker = IstiakPlayerWorker.shared

    private(set) var currentClip: Clip?
    
    private let player = AVPlayer()
    private var periodicObserver: Any!
    
    // State of the player
    private(set) var state = LTNPlayerState.initial {
        didSet {
            guard state != oldValue else { return }
            stateDidChange()
        }
    }
    
    // Type of the player
    private(set) var outputType = LTNPlayerType.local {
        didSet {
            stateDidChange()
        }
    }
    
    private var isPlayingAd: Bool = false
    
    // Chrome cast timer
    private var castTimer: Timer?
    
    public var itemProgress: ((_ seconds: Float, _ duration: Float?) -> Void)?
    
    deinit {
        player.removeObserver(player, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        
        player.automaticallyWaitsToMinimizeStalling = false
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        // Setup chrome cast integration
        self.setupChromeCastListener()
        
        // Setup the LTNPlayer type for this player.
        // self.outputType = CastManager.shared.hasConnectionEstablished ? LTNPlayerType.chromeCast : LTNPlayerType.local
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            debugPrint(error)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
    }
    
    //swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "timeControlStatus" else { return }
        guard object is AVPlayer else { return }
        guard currentClip != nil else { return }
        guard player.currentItem != nil else { return }
        switch player.timeControlStatus {
        case .paused:
            state = .isPaused
        case .playing:
            state = .isPlaying
        case .waitingToPlayAtSpecifiedRate:
            state = .isBuffering
        default: break
        }
    }
    
    public func play(withClip clip: Clip) {
        
        // Guard for playing ad clip
        guard !isPlayingAd else { return }
        
        self.state = .isBuffering
        self.currentClip = clip
        isPlayingAd = clip is AdClip
        
        // Check if we have locally stored the clip else stream it.
        guard let clipUrl = URL(string: clip.uri) else {
            debugPrint("Clip does not have an URI to play from")
            return
        }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: IstiakPlayerCacheManager.shared.getCacheUrl(clipUrl) ?? clipUrl))
        
        // Setup progress notification for the current item playing
        setupProgressObserver()
        
        // If the type is Chrome Cast - play on the chrome cast.
        if outputType == .chromeCast {
            self.startCastPlay()
            return
        }
        
        // Guard for an audio clip and check for RSS or saved progress of clip.
        guard let audioClip = clip as? AudioClip else {
            self.player.play()
            return
        }
        
        // Get progress second for this clip
        let progressSeconds = worker.getProgress(forClip: audioClip.id)
        debugPrint("Progress in seconds for clip", progressSeconds)
        
        // RSS Stuff
        // This is a RSS clip - needs to tell when to start / end.
        if let startMiliSecond = audioClip.playbackStart, let endMiliSecond = audioClip.playbackEnd, endMiliSecond > 0 {
            // Move to last progressed second of the clip
            seek(to: startMiliSecond + (progressSeconds * 1000), completion: { (isFinished) in
                debugPrint("Seek to time is finished:", isFinished)
                self.player.play()
            })
        } else {
            // Move to last progressed second of the clip
            seek(to: progressSeconds * 1000, completion: { (isFinished) in
                debugPrint("Seek to time is finished:", isFinished)
                self.player.play()
            })
        }
        
    }
    
    func playJingle() {
        guard outputType == .local, let jingleURL = DataCacheManager.shared.jingleURL, let url = URL(string: jingleURL) else {
            didPlayToEndTime()
            return
        }
        currentClip = JingleClip(id: 0, title: "", uri: "")
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
    }
    
    // Play
    func play() {
        if outputType == .chromeCast {
            self.continueCastPlay()
        } else {
            player.play()
        }
    }
    
    // Pause
    func pause() {
        if outputType == .chromeCast {
            self.pauseCastPlay()
        } else {
            player.pause()
        }
    }
    
    public func resetPlayer() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        currentClip = nil
        state = .initial
        worker.resetUserPreferences()
    }
    
    public func markCurrentClipAsListenedTo() {
        
//
//        self.worker.saveListenedTo(withClip: ListenedClip(id: audioClip.id))
    
//        // Check if this collection is listened through
//        guard let collection = audioClip.collection else { return }
//
//        let numberOfListenedClipsInCollection = LTNPlayerWorker.shared.getListenedToClips().filter( { $0.collectionId == collection.id }).count
//        debugPrint("Listened to \(numberOfListenedClipsInCollection) clips out of \(collection.clipsCount)")
//        if numberOfListenedClipsInCollection == collection.clipsCount {
//            debugPrint("[LISTENED TO COLLECTION] - ", collection.title)
//            self.worker.saveListenedTo(withCollection: collection.id)
//        }
        
    }
    
    public func seek(to miliSecond: Int, completion: ((Bool) -> Void)?) {
        let miliSecondDouble = Double(miliSecond) / Double(1000)
        let seekCMTime = CMTime(seconds: miliSecondDouble, preferredTimescale: 1000)
        player.seek(to: seekCMTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (done) in
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
            completion?(done)
        }
    }
    
    public func skipFoward() {
        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        
        var seekCMTime = CMTime(seconds: currentSeconds + 15, preferredTimescale: 1)
        if #available(iOS 13.0, *) {
            seekCMTime = CMTime(seconds: currentSeconds + 10, preferredTimescale: 1)
        }
        
        player.seek(to: seekCMTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
        }
    }
    
    public func skipBackward() {
        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        
        var seekCMTime = CMTime(seconds: currentSeconds - 15, preferredTimescale: 1)
        if #available(iOS 13.0, *) {
            seekCMTime = CMTime(seconds: currentSeconds - 10, preferredTimescale: 1)
        }
        
        player.seek(to: seekCMTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { _ in
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
        }
    }
    
    private func setupProgressObserver() {
        
        if let periodicObserver = self.periodicObserver {
            self.periodicObserver = nil
            player.removeTimeObserver(periodicObserver)
        }
        
        let timeScale = CMTimeScale(NSEC_PER_MSEC)
        let time = CMTime(seconds: 0.25, preferredTimescale: timeScale)
        periodicObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { [weak self] progressTime in

            var seconds = CMTimeGetSeconds(progressTime)
            if seconds < 1.0, self?.state != .isPaused {
               self?.state = .isPlaying
            }

            // Check for - AdClip
            if let adClip = self?.currentClip as? AdClip {
                
                if Int(seconds) <= adClip.durationTimeSeconds {
                    self?.itemProgress?(Float(seconds), Float(adClip.durationTimeSeconds))
                }
                if Int(seconds) == adClip.durationTimeSeconds {
                    debugPrint("[AdClip] - Did play to end")
                    self?.didPlayToEndTime()
                }
                
            // Check for - AudioClip
            } else if let audioClip = self?.currentClip as? AudioClip {
                
                // Check if startTime then minus that to the
                if let miliSecond = audioClip.playbackStart, seconds > 0 {
                    let miliSecondDouble = Double(miliSecond) / Double(1000)
                    seconds -= miliSecondDouble
                }
                
                if Int(seconds) <= audioClip.durationTimeSeconds {
                    self?.itemProgress?(Float(seconds), Float(audioClip.durationTimeSeconds))
                }
                
                // If every 3rd percentage - save
                // let progressPercentage = Int(seconds) / audioClip.durationTimeSeconds * 100
                if Int(seconds) > 10, Int(seconds) % 5 == 0 {
                    self?.worker.saveProgress(withSeconds: Int(seconds), withClip: audioClip.id)
                }

                // Check if endTime is equal or greater than
                if let startSeconds = audioClip.playbackStart, startSeconds > 0, let endSeconds = audioClip.playbackEnd, endSeconds > 0, (Float64(audioClip.duration?.millisecond ?? 0) / 1000.0).isLessThanOrEqualTo(seconds) {
                    debugPrint("[Clip RSS] - Did play to end")
                    self?.didPlayToEndTime()
                }
                
            } else if let _ = self?.currentClip as? ProviderClip {
                self?.itemProgress?(Float(seconds), 0.0)
            }

        })
    }
    
    @objc private func didPlayToEndTime() {
        debugPrint("[FINISHED CLIP]")
        
        // Remove the observers
        if let periodicObserver = self.periodicObserver {
            self.periodicObserver = nil
            self.player.removeTimeObserver(periodicObserver)
        }
        
        // Mark clip as listened to
        if let adClip = currentClip as? AdClip {
            DataCacheManager.shared.markClipAsListenedTo(withAdClip: adClip)
        
            
        } else if currentClip != nil {
            self.markCurrentClipAsListenedTo()
            debugPrint("[MARKED CLIP AS LISTENED TO]")
        }
        
        isPlayingAd = false
        
        // Set state to isFinished and current clip to nil
        state = .isFinished
        
    }
    
    private func stateDidChange() {
        switch state {
        case .initial:
            NotificationCenter.default.post(name: .initial, object: nil)
        case .isBuffering:
            NotificationCenter.default.post(name: .isBuffering, object: nil)
        case .isPaused:
            NotificationCenter.default.post(name: .isPaused, object: currentClip)
        case .isFinished:
            NotificationCenter.default.post(name: .isFinished, object: currentClip)
        case .isPlaying:
            NotificationCenter.default.post(name: .isPlaying, object: currentClip)
        }
        
        updateNowPlayingInfoCenter()
    }
    
    private func updateNowPlayingInfoCenter() {
        
        var nowPlayingInfo = [String: Any]()
        var imageURL: URL!
        
        if let clip = currentClip as? AudioClip {
            nowPlayingInfo = [MPMediaItemPropertyTitle: clip.title,
            MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
            MPMediaItemPropertyPlaybackDuration: clip.durationTimeSeconds,
            MPMediaItemPropertyArtist: clip.provider?.name ?? "",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime().seconds)]
            guard let url = URL(string: clip.provider?.logo?.url ?? "") else { return }
            imageURL = url
        } else if let clip = currentClip as? ProviderClip {
            nowPlayingInfo = [MPMediaItemPropertyTitle: clip.title,
            MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
            MPMediaItemPropertyPlaybackDuration: 0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime().seconds)]
            guard let url = URL(string: clip.logo ?? "") else { return }
            imageURL = url
        } else if let clip = currentClip as? AdClip {
            nowPlayingInfo = [MPMediaItemPropertyTitle: clip.title,
            MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
            MPMediaItemPropertyPlaybackDuration: clip.durationTimeSeconds,
            MPMediaItemPropertyArtist: clip.providerName ?? "",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime().seconds)]
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: UIImage(named: "Icon")!.size) { _ in
                    return UIImage(named: "Icon")!
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            return
        } else {
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: imageURL) { (result) in
            switch result {
            case .success(let image):
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.image.size) { _ in
                        return image.image
                }
            default: break
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    
    }
    
    
    // MARK: - Handle Interuptions
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else { return }
        switch type {
        case .began:
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            guard AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) else { return }
            player.play()
        @unknown default:
            break
        }
    }
    
}


// MARK: Chrome Cast Setup

extension IstiakPlayer {

    private func setupChromeCastListener() {
//        let _: (CastSessionStatus) -> Void = { [weak self] status in
//            switch status {
//            case .started:
//                self?.outputType = .chromeCast
//                self?.startCastPlay()
//            case .resumed:
//                self?.outputType = .chromeCast
//                self?.continueCastPlay()
//            case .ended, .failedToStart:
//                self?.outputType = .local // Change to local if the session has ended or failedToStart.
//            default: break
//            }
//        }
//
//        // TODO: CastManager.shared.addSessionStatusListener(listener: sessionStatusListener)
    }
    
    private func startCastPlay(customAudioClipURL: URL? = nil) {
        
        _ = player.currentTime().seconds
        player.pause()
        
        guard (currentClip as? AudioClip) != nil else {
            // Play the custom audio clip url
            /* let castMediaInfo = CastManager.shared.buildMediaInformation(with: "", with: "", with: "ListenToNews", with: TimeInterval(2), with: customAudioClipURL?.absoluteString ?? "", with: GCKMediaStreamType.buffered, with: "")
            print("Custom URL to play on chrome:\n", customAudioClipURL?.absoluteString)
            CastManager.shared.startSelectedItemRemotely(castMediaInfo, at: currentTime) { (done) in
                if !done {
                    self.state = .isPaused
                } else {
                    self.scheduleCastTimer()
                    self.state = .isPlaying
                }
            }*/
            return
        }
/*
        // Play clip
        let castMediaInfo = CastManager.shared.buildMediaInformation(with: clip.title, with: clip.infoStringMaximized, with: "ListenToNews", with: TimeInterval(clip.durationTimeSeconds), with: clip.uri ?? "", with: GCKMediaStreamType.buffered, with: clip.providerLogo)
        CastManager.shared.startSelectedItemRemotely(castMediaInfo, at: currentTime) { (done) in
            if !done {
                self.state = .isPaused
            } else {
                self.scheduleCastTimer()
                self.state = .isPlaying
            }
        }
*/
        
    }
    
    private func continueCastPlay() {
        self.state = .isPlaying
//        CastManager.shared.playSelectedItemRemotely(to: nil) { (done) in
//            if !done {
//                self.state = .isPaused
//            }
//        }
    }
    
    private func pauseCastPlay() {
        self.state = .isPaused
//        CastManager.shared.pauseSelectedItemRemotely(to: nil) { (done) in
//            if !done {
//                self.state = .isPaused
//            }
//        }
    }
    
    private func scheduleCastTimer() {
        DispatchQueue.main.async {
            guard self.outputType == .chromeCast else {
                self.castTimer?.invalidate()
                return
            }
            
            switch self.state {
            case .isPlaying, .isPaused:
                self.castTimer?.invalidate()
                self.castTimer = Timer.scheduledTimer(timeInterval: 0.25,
                                                      target: self,
                                                      selector: #selector(self.sendCurrentTimeCastSessionRequest),
                                                      userInfo: nil,
                                                      repeats: true)
            default:
                self.castTimer?.invalidate()
                self.castTimer = nil
            }
        }
    }
    
    @objc private func sendCurrentTimeCastSessionRequest() {
//        CastManager.shared.getSessionCurrentTime { [weak self] (time) in
//            guard let time = time, let clip = self?.currentClip as? AudioClip else { return }
//            let progress = Float(time / TimeInterval(clip.durationTimeSeconds))
//            print("ChromeCast - Progress:", progress)
//
//            if time < 1.0, self?.state != .isPaused {
//               self?.state = .isPlaying
//            }
//
//            // If seconds are the same as the endSecond of the currentclip - the clip has ended (RSS)
//            if let endSecond = clip.playbackEnd, Int(endSecond) <= Int(time) {
//                self?.didPlayToEndTime()
//                return
//            }
//
//            if progress >= 0.98 {
//                self?.didPlayToEndTime()
//                return
//            }
//
//            self?.itemProgress?(Float(time), Float(clip.durationTimeSeconds))
//        }
    }
    
}
