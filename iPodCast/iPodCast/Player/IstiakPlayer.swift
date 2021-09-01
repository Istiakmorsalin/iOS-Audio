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
    public var playebackRate: Float = 1.0
    private let seekTime = 15000
    
    // State of the player
    private(set) var state = IstiakPlayerState.initial {
        didSet {
            guard state != oldValue else { return }
            stateDidChange()
        }
    }
    
    // Type of the player
    private(set) var outputType = IstiakPlayerType.local
    
    private var isPlayingAd: Bool = false
    
    // Chrome cast timer
    private var castTimer: Timer?
    
    public var itemProgress: ((_ seconds: Float, _ duration: Float?) -> Void)?
    let volumeView = MPVolumeView()
       
    deinit {
        player.removeObserver(player, forKeyPath: "timeControlStatus")
        NotificationCenter.default.removeObserver(self)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    override init() {
        super.init()
        
        player.automaticallyWaitsToMinimizeStalling = false
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didPlayToEndTime),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            debugPrint(error)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        
        // Setup chrome cast integration
        self.setupChromeCastListener()
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
            if outputType == .chromeCast {
                self.pauseCastPlayer()
            }
        case .playing:
            state = .isPlaying
            if outputType == .chromeCast {
                self.playCastPlayer()
            }
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
       
        let url = IstiakPlayerCacheManager.shared.getCacheUrl(clipUrl) ?? clipUrl
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.pause()
        self.state = .isPaused
        
        let duration = self.getClipDuration(clip)
        self.itemProgress?(Float(0), duration)
        
        guard let audioClip = clip as? AudioClip else {
            if outputType == .chromeCast {
                self.startCastingMediaURL(url: url,playbackRate: self.playebackRate) { done in
                    if done {
                        self.player.play()
                        self.state = .isPlaying
                        self.player.rate = self.playebackRate
                    }
                }
            } else {
                self.player.play()
                self.state = .isPlaying
                self.player.rate = self.playebackRate
            }
            return
            
        }
        
        // Get progress second for this clip
        let progressSeconds = worker.getProgress(forClip: audioClip.id)
        debugPrint("Progress in seconds for clip", progressSeconds)
        
        // RSS Stuff
        // This is a RSS clip - needs to tell when to start / end.
        if let startMiliSecond = audioClip.playbackStart, let endMiliSecond = audioClip.playbackEnd, endMiliSecond > 0 {
            // Move to last progressed second of the clip
            let miliSecond = startMiliSecond + (progressSeconds * 1000)
            let seconds = Double(miliSecond) / Double(1000)
            let seekCMTime = CMTime(seconds: seconds, preferredTimescale: 1000)
        
            loadAudioClip(seekCMTime: seekCMTime)
           
        } else {
            // Move to last progressed second of the clip
            let seekCMTime = CMTime(seconds: Double(progressSeconds), preferredTimescale: 1000)
            loadAudioClip(seekCMTime: seekCMTime)
        }
   
    }
    
    public func changeRate(atRate: Float) {
        playebackRate = atRate
        NotificationCenter.default.post(name: .changeSpeed, object: nil)
        //remove current set of speed of the player
        if(state == .isPlaying) {
            self.player.rate = playebackRate
            if outputType == .chromeCast {
//                GoogleCastManager.shared.changePlaybackRate(playebackRate)
            }
        }
    }
    
    private func loadAudioClip(seekCMTime: CMTime) {
        self.player.seek(
            to: seekCMTime,
            toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero) { (done) in
           
            MPNowPlayingInfoCenter
                .default()
                .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
          
            if self.outputType == .chromeCast {
                self.startCastPlay( shouldAutoPlay: true, playbackRate: self.playebackRate) { succeed in
                    if succeed {
                        self.setupProgressObserver()
                        self.player.play()
                        self.state = .isPlaying
                        self.player.rate = self.playebackRate
                    }
                }
            } else {
                self.setupProgressObserver()
                self.player.play()
                self.state = .isPlaying
                self.player.rate = self.playebackRate
            }
        }
    }
    
    
    func playJingle() {
        
        guard let jingleURL = DataCacheManager.shared.jingleURL, let url = URL(string: jingleURL) else {
            didPlayToEndTime()
            return
        }
        
        currentClip = JingleClip(id: 0, title: "", uri: "")
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.pause()
        self.state = .isPaused
        if outputType == .chromeCast {
            self.startCastingMediaURL(url: url,playbackRate: playebackRate) { done in
                if done {
                    self.player.play()
                    self.state = .isPlaying
                    self.player.rate = self.playebackRate
                }
            }
        } else {
            player.play()
            self.state = .isPlaying
            self.player.rate = self.playebackRate
        }
        
    }
    
    // Play
    func play() {
        player.play()
        if outputType == .chromeCast {
            self.playCastPlayer()
//            GoogleCastManager.shared.changePlaybackRate(playebackRate)
        }
        self.state = .isPlaying
        self.player.rate = self.playebackRate
    }
    
    // Pause
    func pause() {
        player.pause()
        if outputType == .chromeCast {
            self.pauseCastPlayer()
        }
        self.state = .isPaused
    }
    
    public func resetPlayer() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        currentClip = nil
        state = .initial
        worker.resetUserPreferences()
//        _ = GoogleCastManager.shared.endSession()
    }
    
    public func markCurrentClipAsListenedTo() {
        guard let audioClip = currentClip as? AudioClip else { return }
        
        self.worker.saveListenedTo(withClip: ListenedClip(id: audioClip.id))
    }
    
    public func seek(to miliSecond: Int, completion: ((Bool) -> Void)?) {
        let miliSecondDouble = Double(miliSecond) / Double(1000)
        let seekCMTime = CMTime(seconds: miliSecondDouble, preferredTimescale: 1000)
        player.seek(
            to: seekCMTime,
            toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero) { (done) in
            MPNowPlayingInfoCenter
                .default()
                .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
            completion?(done)
           
        }
        
        if self.outputType == .chromeCast {
            self.seekCastPlayerTime(to: seekCMTime, completion: nil)
        }
    }
    
    public func skipFoward() {
        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        
        var seekCMTime = CMTime(seconds: currentSeconds + 15, preferredTimescale: 1)
        if #available(iOS 13.0, *) {
            seekCMTime = CMTime(seconds: currentSeconds + 10, preferredTimescale: 1)
        }
        
        player.seek(
            to: seekCMTime, toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero) { _ in
            MPNowPlayingInfoCenter
                .default()
                .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
           
        }
        if self.outputType == .chromeCast {
            self.seekCastPlayerTime(to: seekCMTime, completion: nil)
        }
    }
    
    public func skipBackward() {
        
        let currentSeconds = CMTimeGetSeconds(player.currentTime())
        
        var seekCMTime = CMTime(seconds: currentSeconds - 15, preferredTimescale: 1)
        if #available(iOS 13.0, *) {
            seekCMTime = CMTime(seconds: currentSeconds - 10, preferredTimescale: 1)
        }
        
        player.seek(
            to: seekCMTime,
            toleranceBefore: CMTime.zero,
            toleranceAfter: CMTime.zero) { _ in
            MPNowPlayingInfoCenter
                .default()
                .nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
           
            
        }
        if self.outputType == .chromeCast {
            self.seekCastPlayerTime(to: seekCMTime, completion: nil)
        }
    }
    
    public func seekForward() {
        let currentTimeInMiliSeconds = self.player.currentTime().seconds * 1000
        seek(to: Int(currentTimeInMiliSeconds) + seekTime, completion: nil)
    }
    
    
    public func seekBackward() {
        let currentTimeInMiliSeconds = self.player.currentTime().seconds * 1000
        seek(to: Int(currentTimeInMiliSeconds) - seekTime, completion: nil)
    }

    public func getDeviceVolume() -> Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
    
    public func handleVolumeChange(_ volume: Float) {
//        NotificationCenter.default.post(name: .volumeChanged, object: nil)
//        if outputType == .chromeCast {
//            GoogleCastManager.shared.setDeviceVolume(volume)
//        }
    }
    
    public func changeVolume(_ volume: Float) {
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        slider?.value = volume
    }
    
    @objc private func didPlayToEndTime() {
        debugPrint("[FINISHED CLIP]")
        
        removeProgressObserver()
        
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
            nowPlayingInfo = [
                MPMediaItemPropertyTitle: clip.title,
                MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
                MPMediaItemPropertyPlaybackDuration: clip.durationTimeSeconds,
                MPMediaItemPropertyArtist: clip.provider?.name ?? "",
                MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime().seconds)
            ]
            guard let url = URL(string: clip.provider?.logo?.url ?? "") else { return }
            imageURL = url
        } else if let clip = currentClip as? ProviderClip {
            nowPlayingInfo = [
                MPMediaItemPropertyTitle: clip.title,
                MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
                MPMediaItemPropertyPlaybackDuration: 0,
                MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime().seconds)
            ]
            guard let url = URL(string: clip.logo ?? "") else { return }
            imageURL = url
        } else if let clip = currentClip as? AdClip {
            nowPlayingInfo = [
                MPMediaItemPropertyTitle: clip.title,
                MPMediaItemPropertyMediaType: MPMediaType.podcast.rawValue,
                MPMediaItemPropertyPlaybackDuration: clip.durationTimeSeconds,
                MPMediaItemPropertyArtist: clip.providerName ?? "",
                MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime().seconds)
            ]
            let artworkItem = MPMediaItemArtwork(
                boundsSize: UIImage(named: "Icon")!.size) { _ in
                return UIImage(named: "Icon")!
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artworkItem
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
            play()
        @unknown default:
            break
        }
    }
    
}


// MARK: Chrome Cast Setup

extension IstiakPlayer {
    
    private func setupChromeCastListener() {
//        let sessionStatusListener: (CastSessionStatus) -> Void = { [weak self] status in
//            switch status {
//            case .switchedToRemote:
//                self?.switchToRemotePlayback()
//            case .switchedToLocal:
//                self?.switchToLocalPlayback()
//            case .finishPlaying:
//                if self?.state == .isPlaying {
//                    self?.didPlayToEndTime()
//                }
//            }
//        }
//        GoogleCastManager.shared.addSessionStatusListener(listener: sessionStatusListener)
    }
    
    func switchToLocalPlayback() {
        
//        if outputType == .local {
//            return
//        }
//        outputType = .local
////        if let time = GoogleCastManager.shared.lastKnownStreamPosition {
////            self.seek(to: Int(time * 1000)) { _ in
////                self.setupProgressObserver()
////                self.player.isMuted = false
////
////            }
////        } else {
////            self.setupProgressObserver()
////            self.player.isMuted = false
////        }
//
//        self.setupProgressObserver()
//        self.player.isMuted = false
        
    }
    
    func switchToRemotePlayback() {
        
//        if outputType == .chromeCast {
//            return
//        }
//
//        let shouldAutoPlay =  self.state != .isPaused
//
//        player.isMuted = true
//        player.pause()
//        self.state = .isPaused
//        outputType = .chromeCast
//
//        startCastPlay( shouldAutoPlay: shouldAutoPlay, playbackRate: playebackRate) { succeed in
//            if succeed {
//                self.setupProgressObserver()
//                if shouldAutoPlay {
//                    self.player.play()
//                    self.state = .isPlaying
//                    self.player.rate = self.playebackRate
//                }
//            }
//        }
        
    }
    
    
//    private func getCurrentMediaInfo() -> [String: Any?] {
////        var nowPlayingInfo = [String: Any?]()
////
////        if let clip = currentClip as? AudioClip {
////            nowPlayingInfo = [
////                "title": clip.title,
////                "description": clip.infoString,
////                "duration": clip.durationTimeSeconds
////            ]
////
////        } else if let clip = currentClip as? ProviderClip {
////            nowPlayingInfo = [
////                "title": clip.title,
////                "description": clip.title,
////                "duration": clip.durationTimeSeconds
////            ]
////        } else if let clip = currentClip as? AdClip {
////            nowPlayingInfo = [
////                "title": clip.title,
////                "description": clip.providerName ?? "Istiak",
////                "duration": clip.durationTimeSeconds
////            ]
////        }
////        return nowPlayingInfo
//    }
    
    private func startCastingMediaURL(url: URL, playbackRate: Float,completion: @escaping ((Bool) -> Void)) {
        DispatchQueue.main.async {
            // Play clip
//            let mediaInfo = self.getCurrentMediaInfo()
//
//            let castMediaInfo = GoogleCastManager.shared.buildMediaInformationWith(
//                title: mediaInfo["title"] as? String ?? "",
//                description: mediaInfo["description"] as? String ?? "",
//                duration: mediaInfo["duration"] as? TimeInterval ?? 0,
//                audioUrl: url,
//                thumbnailUrl: mediaInfo["thumbnailUrl"] as? String
//            )
//
//            GoogleCastManager.shared.startSelectedItemRemotely(castMediaInfo,autoPlay: true, at: 0,playbackRate: playbackRate) { (done) in
//                completion(done)
//            }
      }
       
    }
    
    
    private func startCastPlay( shouldAutoPlay : Bool, playbackRate: Float,completion: @escaping ((Bool) -> Void)) {
//        DispatchQueue.main.async {
//            let currentTime = self.player.currentTime().seconds
//
//            guard let clip = self.currentClip, let  url = URL(string: clip.uri) else {
//                completion(false)
//                return
//
//            }
//            let mediaInfo = self.getCurrentMediaInfo()
//            // Play clip
//            let castMediaInfo = GoogleCastManager.shared.buildMediaInformationWith(
//                title: mediaInfo["title"] as? String ?? "",
//                description: mediaInfo["description"] as? String ?? "",
//                duration: mediaInfo["duration"] as? TimeInterval ?? 0,
//                audioUrl: url,
//                thumbnailUrl: mediaInfo["thumbnailUrl"] as? String
//            )
//
//            GoogleCastManager.shared.startSelectedItemRemotely(castMediaInfo,autoPlay: shouldAutoPlay, at: currentTime, playbackRate: playbackRate) { (done) in
//                completion(done)
//            }
//        }
        
    }
    
    private func playCastPlayer() {
        
//        GoogleCastManager.shared.playSelectedItemRemotely(to: nil) { (done) in
//            self.sendCurrentTimeCastSessionRequest()
//            if done {
//                self.state = .isPlaying
//            }
//        }
    }
    
    private func pauseCastPlayer() {
        
//        GoogleCastManager.shared.pauseSelectedItemRemotely(to: nil) { (done) in
//            self.sendCurrentTimeCastSessionRequest()
//            if done {
//                self.state = .isPaused
//            }
//
//        }
    }
    
    private func seekCastPlayerTime(to seekCMTime: CMTime, completion: ((Bool) -> Void)?) {
//        let time = CMTimeGetSeconds(seekCMTime)
//        if self.state == .isPlaying {
//            GoogleCastManager.shared.playSelectedItemRemotely(to: time) { succeeded in
//                self.sendCurrentTimeCastSessionRequest()
//                completion?(succeeded)
//            }
//        } else {
//            GoogleCastManager.shared.pauseSelectedItemRemotely(to: time) { succeeded in
//                self.sendCurrentTimeCastSessionRequest()
//                completion?(succeeded)
//            }
//        }
    }
    
}

/// Player observers
extension IstiakPlayer {
    
    //MARK: LTN player observer register / unregister
    private func setupProgressObserver() {
        
//        removeProgressObserver()
//        if outputType == .local {
//            registerLocalPlayerObserver()
//        } else {
//            registerCastPlayerObserver()
//        }
        
    }
    
    private func removeProgressObserver() {
//        unRegisterLocalPlayerObserver()
//        unRegisterCastPlayerObserver()
        
    }
    
    //MARK:- Local player observer register / unregister
    
    private func registerLocalPlayerObserver() {
        
//        let timeScale = CMTimeScale(NSEC_PER_MSEC)
//        let time = CMTime(
//            seconds: 0.25,
//            preferredTimescale: timeScale
//        )
//        periodicObserver = player.addPeriodicTimeObserver(
//            forInterval: time,
//            queue: .main,
//            using: { [weak self] progressTime in
//                guard self?.outputType == .local else { return }
//                let seconds = CMTimeGetSeconds(progressTime)
//                self?.playerPlaying(at: seconds)
//
//            }
//        )
    }
    
    private func unRegisterLocalPlayerObserver() {
        
//        if let periodicObserver = self.periodicObserver {
//            self.periodicObserver = nil
//            player.removeTimeObserver(periodicObserver)
//        }
    }
    
    //MARK:- Cast player observer register / unregister
    private func registerCastPlayerObserver() {
//
//        self.castTimer?.invalidate()
//        self.castTimer = Timer.gck_scheduledTimer(
//            withTimeInterval: 0.25,
//            weakTarget: self,
//            selector: #selector(self.sendCurrentTimeCastSessionRequest),
//            userInfo: nil,
//            repeats: true
//        )
    }
    
    private func unRegisterCastPlayerObserver() {
//        self.castTimer?.invalidate()
//        self.castTimer = nil
    }
    
    @objc private func sendCurrentTimeCastSessionRequest() {
        
//        GoogleCastManager.shared.getSessionCurrentTime { [weak self] (time) in
//            guard let timeInterval = time, self?.outputType == .chromeCast  else { return }
//            let seconds = Float64(timeInterval)
//            self?.playerPlaying(at: seconds)
//            let seekCMTime = CMTime(seconds: seconds, preferredTimescale: 1000)
//            self?.player.seek(to: seekCMTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (done) in
//                MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(seekCMTime)
//
//            }
//        }
    }
    
    //MARK:- Play time tracker
    private func playerPlaying(at time: Float64) {
        
//        var seconds = time
//        let duration = getClipDuration(self.currentClip)
//        // Check for - AdClip
//        if let adClip = self.currentClip as? AdClip {
//
//            if Int(seconds) <= adClip.durationTimeSeconds {
//                self.itemProgress?(Float(seconds), duration)
//            }
//            if Int(seconds) >= adClip.durationTimeSeconds {
//                debugPrint("[AdClip] - Did play to end")
//                self.didPlayToEndTime()
//            }
//
//            // Check for - AudioClip
//        } else if let audioClip = self.currentClip as? AudioClip {
//
//            // Check if startTime then minus that to the
//            if let miliSecond = audioClip.playbackStart, seconds > 0 {
//                let miliSecondDouble = Double(miliSecond) / Double(1000)
//                seconds -= miliSecondDouble
//            }
//
//            if Int(seconds) <= audioClip.durationTimeSeconds {
//                self.itemProgress?(Float(seconds), duration)
//            }
//
//            // Check if endTime is equal or greater than
//            if let startSeconds = audioClip.playbackStart, startSeconds > 0,
//               let endSeconds = audioClip.playbackEnd, endSeconds > 0,
//               Float64(audioClip.durationTimeSeconds).isLessThanOrEqualTo(seconds) {
//                debugPrint("[Clip RSS] - Did play to end")
//                self.didPlayToEndTime()
//            }
//
//        } else if let _ = self.currentClip as? ProviderClip {
//            self.itemProgress?(Float(seconds), duration)
//        }
    }
    
    private func getClipDuration(_ clip: Clip?) -> Float {
        if let adClip = self.currentClip as? AdClip {
            return Float(adClip.durationTimeSeconds)
            // Check for - AudioClip
        } else if let audioClip = self.currentClip as? AudioClip {
            
            return Float(audioClip.durationTimeSeconds)
            
        } else if let provider = self.currentClip as? ProviderClip {
            return Float(provider.durationTimeSeconds)
        } else {
            return 0
        }
        
    }
}
