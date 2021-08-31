//
//

import UIKit
import MediaPlayer
import CoreMedia

class IstiakPlayerManager {
    
    static let shared = IstiakPlayerManager()
    private let player = IstiakPlayer()
   
    var timeSlotAd : AdClip?
    var clipForPlayAd: Clip?
    // Ads
    private var isAdAllowed: Bool = true
    private var adFrequency: Int = DataCacheManager.shared.adFrequency ?? 8
    private var numberOfClipsPlayed: Int = 0
    private var hasPlayedEditorSpeak: Bool = false
    
    // Public
    public var itemProgress: ((_ seconds: Float, _ duration: Float?) -> Void)?
    public var nextItem: AudioClip? {
        return queue.first
    }
    public var currentItem: Clip? {
        if let audioClip = player.currentClip as? AudioClip {
            return audioClip
        } else if let adClip = player.currentClip as? AdClip {
            return adClip
        } else if let jingleClip = player.currentClip as? JingleClip {
            return jingleClip
        } else if let providerClip = player.currentClip as? ProviderClip {
            return providerClip
        }
        return player.currentClip
    }
    public var state: LTNPlayerState {
        return player.state
    }
    
    public var isPlaying: Bool {
        switch player.state {
        case .isPlaying: return true
        default: return false
        }
    }
    
    // This queue contains all types of clips AudioClip and ProviderClip
    private(set) var queue: [AudioClip] = []
    
    deinit {
        /// Remove observers
        MediaCommandCenter.removeObserver(self)
        ///
    }
    
    init() {
        
        // Add observers for the IstiakPlayerManager
        NotificationCenter.default.addObserver(self, selector: #selector(isFinished), name: .isFinished, object: nil)
        
        player.itemProgress = {  [weak self] seconds, duration in
            guard !(self?.currentItem is JingleClip) else { return }
            self?.itemProgress?(seconds, duration)
        }
        
        /// Begin Media Command observing
        MediaCommandCenter.addObserver(self)
        MediaCommandCenter.observedCommands = [.togglePlayPause, .skipBackward, .nextTrack, .pause, .play]
        ///
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            
            guard let event = event as? MPChangePlaybackPositionCommandEvent, let clip = self.currentItem as? AudioClip else { return .commandFailed }
            
            let ms = Int(event.positionTime * 1000)
            
            guard let startMiliSecond = clip.playbackStart, let _ = clip.playbackEnd else {
                self.player.seek(to: ms, completion: nil)
                return .success
            }
            
            // Move to last progressed second of the clip
            let seekToTime = ms + startMiliSecond
            self.player.seek(to: seekToTime, completion: nil)
            return .success
        }
        
        
    }
    
    public func addToQueue(withClips clips: [AudioClip], atFirst: Bool, showAddedToQueue: Bool) {
        
        // Manipulate the clips to add a provider clip if needed.
        var tempQueue = [AudioClip]()
        for clip in clips {
            
            // Check if clip is premium and user is premium, else continue
            /* if clip.isPremium {
                guard UserManager.shared.isSubscribed else { continue }
            }*/
            
            guard let provider = DataCacheManager.shared.providers.first(where: { $0.id == clip.provider?.id }),
                let providerURI = provider.uri else {
                    tempQueue.append(clip)
                continue
            }
            
            let providerClip = ProviderClip(id: provider.id, title: clip.provider?.name ?? "", uri: providerURI, logo: provider.logo?.url, collection: nil)
            clip.providerClip = providerClip
            tempQueue.append(clip)
            
            
            if showAddedToQueue {
                let audioClip = clip
            }
        }
        
        if atFirst {
            queue.insert(contentsOf: tempQueue, at: 0)
        } else {
            queue.append(contentsOf: tempQueue)
        }
        
        if showAddedToQueue {
            NotificationCenter.default.post(name: .addedToQueue, object: nil)
        }
        
    }
    
    public func play(withClips clips: [AudioClip], startClip: Clip?, endClip: Clip?, isTimeSlot: Bool, timeslotAd: AdClip? = nil, overwrite: Bool) {
        debugPrint("Play clips...")

        // Track event play - to
        guard let audioClip = clips.first else { return }
                
        numberOfClipsPlayed += 1
        
        if overwrite {
            queue.removeAll()
        }
        
        // If first time playing a clip - play welcome clip
        let numberOfAppOpenings = UserDefaults.standard.integer(forKey: "numberOfAppOpenings")
        if let introductionClip = DataCacheManager.shared.editorSpeaks.first(where: { $0.groupId == numberOfAppOpenings }),
            !hasPlayedEditorSpeak {
            hasPlayedEditorSpeak = true
            let clip = AudioClip(id: introductionClip.id, title: introductionClip.title, uri: introductionClip.uri)
            clip.category = Category(id: 0, name: "24syv", identifier: nil, color: "e84139", image: nil, subscribed: false)
            clip.provider = DataCacheManager.shared.radio24SyvProvider
            queue.append(clip)
        }
        
        /// disabled push notification alert from player manager
//        // Show popup when first time
//        if numberOfAppOpenings == 1 {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "shouldAskForPushNotifications"), object: nil)
//        }
        
        // Append start clip if we have one
        if let clip = startClip {
            let startAudioClip = AudioClip(id: clip.id, title: clip.title, uri: clip.uri)
            startAudioClip.category = Category(id: 0, name: "24syv", identifier: nil, color: "e84139", image: nil, subscribed: false)
            startAudioClip.provider = DataCacheManager.shared.radio24SyvProvider
            startAudioClip.isTimeslot = isTimeSlot
            queue.append(startAudioClip)
        }
        
        // Manipulate the clips to add a provider clip if needed.
        for clip in clips {

            // Check if clip is premium and user is premium, else continue
            /*if clip.isPremium {
                guard UserManager.shared.isSubscribed else { continue }
            }*/
            
            guard let provider = DataCacheManager.shared.providers.first(where: { $0.id == clip.provider?.id }),
                let providerURI = provider.uri else {
                queue.append(clip)
                continue
            }
            
            let providerClip = ProviderClip(id: provider.id, title: clip.provider?.name ?? "", uri: providerURI, logo: provider.logo?.url, collection: nil)
            clip.providerClip = providerClip
            queue.append(clip)
        }
        
        // Append end clip if we have one
        if let clip = endClip {
            let endAudioClip = AudioClip(id: clip.id, title: clip.title, uri: clip.uri)
            endAudioClip.category = Category(id: 0, name: "24syv", identifier: nil, color: "e84139", image: nil, subscribed: false)
            endAudioClip.provider = DataCacheManager.shared.radio24SyvProvider
            endAudioClip.isTimeslot = isTimeSlot
            queue.append(endAudioClip)
        }
        
        // if user is not subsribed, ad will be played after playing end clip of time slot. for now we are storing the ad.
        if  isTimeSlot, let adClip = timeslotAd, let timeslotEndClip = endClip {
            storeTimeslotAd(adClip: adClip, endClip: timeslotEndClip)
        }
        
        // Play the first clip in the queue, providerClip if available.
        guard let nextClip = queue.first else { return }
        guard let providerClip = nextClip.providerClip else {
            isAdAllowed = isAdsAllowed(forProvider: nextClip.provider?.id)
            player.play(withClip: nextClip)
            queue.removeFirst()
            return
        }
        
        player.play(withClip: providerClip)
        
    }
    
    private func storeTimeslotAd(adClip: AdClip, endClip: Clip) {

        clipForPlayAd = endClip
        timeSlotAd = adClip
    }
    
    private func startCachingQueue() {
        queue.prefix(5).forEach { (clip) in
            debugPrint("Try to cache:", clip.title)
            IstiakPlayerCacheManager.shared.cacheAudio(clip.uri)
        }
    }
    
    private func playJingle() {
        debugPrint("Play jingle")
        player.playJingle()
    }
    
    private func playAd() {
        debugPrint("Play ad")
        
        numberOfClipsPlayed = 0
        
        if let adClip = DataCacheManager.shared.sortedAdClips.first {
            player.play(withClip: adClip)
        } else {
            playNext()
        }
        
    }
    
    public func playNext() {
        
        if let audioClip = currentItem {
            //check if current audio clip is endclip of timeslot and any timeslot ad to play
            if audioClip.id == clipForPlayAd?.id, let ad = timeSlotAd {
                player.play(withClip: ad)
                return
            }
        }
        
        // Mark the current clip as listened to
        player.markCurrentClipAsListenedTo()
        
        if let audioClip = currentItem as? AudioClip {
            numberOfClipsPlayed += 1
        
        }
        
        if shouldPlayAd() {
            playAd()
        } else {
            guard shouldPlayNext() else { return }
            if let clip = currentItem as? ProviderClip {
                didFinish(withClip: clip)
            } else {
                didFinish(withClip: JingleClip(id: 0, title: "", uri: ""))
            }
        }
        
        // Start caching of clips
        self.startCachingQueue()
        
    }
    
    private func shouldPlayAd() -> Bool {
        guard let nextClip = queue.first else { return false }
        
        // Check if ad is allowed for this clip else don't play ad after this.
        guard numberOfClipsPlayed > 0,
              numberOfClipsPlayed % adFrequency == 0,
              isAdAllowed else {
            return false
        }
        
        // Check if the next clip allows ad to be played before.
        guard let indexOf = queue.firstIndex(where: { $0.id == nextClip.id }),
            indexOf + 1 < queue.count else {
            return false
        }

        let nextClipTmp = queue[indexOf + 1]
        guard isAdsAllowed(forProvider: nextClipTmp.provider?.id) else {
            return false
        }

        return true
        
    }
    
    public func playPrevious() {
        seek(toPercentage: 0.0)
    }
    
    public func seek(toPercentage progress: Double) {
        guard let clip = currentItem as? AudioClip else { return }
        
        let duration: Double = Double(clip.durationTimeSeconds)
        let ms = Int(duration * progress) * 1000
        
        if let startMiliSecond = clip.playbackStart, let _ = clip.playbackEnd {
            
            // Move to last progressed second of the clip
            let seekToTime = ms + startMiliSecond
            player.seek(to: seekToTime, completion: nil)
            
        } else {
            player.seek(to: ms, completion: nil)
        }
        
    }
    
    func playPauseAction() {
        if player.state == .isPaused {
            player.play()
        } else {
            player.pause()
        }
    }
    
    public func resetPlayer() {
        player.resetPlayer()
        queue.removeAll()
    }
    
    private func isAdsAllowed(forProvider id: Int?) -> Bool {
        guard let id = id else { return false }
        return DataCacheManager.shared.providers.first(where: { $0.id == id })?.isAdsAllowed ?? false
    }
    
    private func didFinish(withClip clip: Clip) {
        if clip.id == clipForPlayAd?.id, let ad = timeSlotAd {
            player.play(withClip: ad)
            return
        }
        
        if clip.id == timeSlotAd?.id {
            timeSlotAd = nil
            clipForPlayAd = nil
        }
       
        if let audioClip = clip as? AudioClip {
            debugPrint("Finished audio clip -", audioClip.title)
            
            numberOfClipsPlayed += 1

            playJingle()
            
        } else if let clip = clip as? AdClip {
            debugPrint("Finished ads clip -", clip.title)
            playJingle()
        } else if let clip = clip as? JingleClip {
            debugPrint("Finished jingle clip", clip.title)
            
            // Jingle have finished to play
            guard !shouldPlayAd() else {
                playAd()
                return
            }
            
            // The next clip to be played
            guard let nextClip = queue.first else { return }
            
            // Check if next clip is premium - then show the is premium content.
            if nextClip.isPremium {

            }
            
            guard let providerClip = nextClip.providerClip else {
                isAdAllowed = isAdsAllowed(forProvider: nextClip.provider?.id)
                player.play(withClip: nextClip)
                queue.removeFirst()
                return
            }
            player.play(withClip: providerClip)
            
        } else if let _ = clip as? ProviderClip {
            debugPrint("Finished provider clip")
            // Provider clip finished - don't play jingle just move on to the next clip in the queue.
            let nextClip = queue.removeFirst()
            
            print("next clip is", nextClip.title)
            isAdAllowed = isAdsAllowed(forProvider: nextClip.provider?.id)
            player.play(withClip: nextClip)
        }
    }
    
    func shouldPlayNext() -> Bool {
        return true
    }
}

extension IstiakPlayerManager: MediaCommandObserver {

    func mediaCommandCenterHandleTogglePlayPause() {
        self.playPauseAction()
    }

    func mediaCommandCenterHandleSkipBackward() {
        player.skipBackward()
    }

    func mediaCommandCenterHandleSkipForward() {
        player.skipFoward()
    }
    
    func mediaCommandCenterHandleNextTrack() {
        self.playNext()
    }
    
    func mediaCommandCenterHandlePreviousTrack() {
        self.playPrevious()
    }
    
    func mediaCommandCenterHandlePause() {
        self.playPauseAction()
    }
    
    func mediaCommandCenterHandlePlay() {
        self.playPauseAction()
    }
    
}

// MARK: - Player Observers Helpers

extension IstiakPlayerManager {
    
    @objc private func isFinished(_ notification: Notification) {
        guard let clip = notification.object as? Clip else { return }
        didFinish(withClip: clip)
    }
    
}
