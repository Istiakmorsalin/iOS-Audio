//
//import Foundation
//import GoogleCast
//
//enum CastSessionStatus {
//    case switchedToLocal
//    case switchedToRemote
//    case finishPlaying
//}
//
//typealias GCKRequestCompletion = (Bool) -> Void
//
//class GoogleCastManager: NSObject {
//
//    static let shared = GoogleCastManager()
//
//    private var sessionManager : GCKSessionManager {
//        return GCKCastContext.sharedInstance().sessionManager
//    }
//    
//    private var sessionStatusListener: ((CastSessionStatus) -> Void)?
//    private var sessionStatus: CastSessionStatus! {
//        didSet {
//            sessionStatusListener?(sessionStatus)
//        }
//    }
//
//    private var mediaClient: GCKRemoteMediaClient?
//    private (set) var lastKnownStreamPosition: TimeInterval?
//    private (set) var lastKnownPlayerState: GCKMediaPlayerState = .unknown
//
//    private var pendingRequests : [GCKRequestID: GCKRequestCompletion] = [:]
//    private var volumeController : GCKUIDeviceVolumeController?
//
//    private struct DeviceSwitchingRequest {
//
//        let device: GCKDevice
//        let deviceSwitchingCompletion: ((Bool) -> Void)?
//    }
//
//    private var switchinRequst : DeviceSwitchingRequest?
//
//    func initialise(id: String) {
//
//        // Set your receiver application ID.
//        let options = GCKCastOptions(
//            discoveryCriteria: GCKDiscoveryCriteria(applicationID: id)
//        )
//        options.physicalVolumeButtonsWillControlDeviceVolume = false
//        options.suspendSessionsWhenBackgrounded = false
//
//        GCKCastContext.setSharedInstanceWith(options)
//        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = false
//
//
//        GCKCastContext.sharedInstance().sessionManager.add(self)
//        volumeController = GCKUIDeviceVolumeController()
//
//    }
//
//    func startDiscovery() {
//        GCKCastContext.sharedInstance().discoveryManager.startDiscovery()
//    }
//
//    func stopDiscovery() {
//        GCKCastContext.sharedInstance().discoveryManager.stopDiscovery()
//    }
//
//    var hasConnectedCastSession: Bool {
//        return GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession()
//    }
//
//    var connectedDevice: GCKDevice? {
//        return GCKCastContext.sharedInstance().sessionManager.currentCastSession?.device
//    }
//
//
//    func addSessionStatusListener(listener: @escaping (CastSessionStatus) -> Void) {
//        self.sessionStatusListener = listener
//    }
//
//    func startSession(with device: GCKDevice) -> Bool {
//        let hasStarted = GCKCastContext.sharedInstance().sessionManager.startSession(with: device)
//        return hasStarted
//    }
//
//    func startNewSession(with device: GCKDevice, completion: ((Bool) -> Void)?) {
//        switchinRequst = DeviceSwitchingRequest(device: device, deviceSwitchingCompletion: completion)
//        _ = endSession()
//    }
//
//    func endSession() -> Bool {
//        let hasBegun = GCKCastContext.sharedInstance().sessionManager.endSessionAndStopCasting(true)
//        return hasBegun
//    }
//
//
//    func numberOfAvailableDevices() -> Int {
//        return Int( GCKCastContext.sharedInstance().discoveryManager.deviceCount )
//    }
//
//    func deviceAtIndex(_ index: Int) -> GCKDevice {
//        return GCKCastContext.sharedInstance().discoveryManager.device(at: UInt(index))
//    }
//
//    func setDeviceVolume(_ volume: Float) {
//        volumeController?.setVolume(volume)
//    }
//
//}
//
//
//
//// MARK: - GCKSessionManagerListener
//
//extension GoogleCastManager: GCKSessionManagerListener {
//    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
//
//        sessionStatus = .switchedToRemote
//
//    }
//
//    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
//
//        sessionStatus = .switchedToRemote
//
//    }
//
//    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
//        sessionStatus = .switchedToLocal
//        if let request = switchinRequst {
//            if error == nil {
//                let hasStarted = startSession(with: request.device)
//                request.deviceSwitchingCompletion?(hasStarted)
//            }
//            switchinRequst = nil
//        }
//
//    }
//
//
//    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
//        sessionStatus = .switchedToLocal
//
//    }
//
//
//    public func sessionManager(_ sessionManager: GCKSessionManager, didSuspend session: GCKSession, with reason: GCKConnectionSuspendReason) {
//
//        sessionStatus = .switchedToLocal
//
//    }
//
//
//    func sessionManager(_: GCKSessionManager,
//                        didFailToResumeSession _: GCKSession, withError _: Error?) {
//
//        sessionStatus = .switchedToLocal
//
//    }
//
//    func attach(to castSession: GCKCastSession) {
//        lastKnownStreamPosition = nil
//        mediaClient = castSession.remoteMediaClient
//        mediaClient?.add(self)
//
//    }
//
//    func detachFromCastSession() {
//        lastKnownStreamPosition = mediaClient?.approximateStreamPosition()
//        mediaClient?.remove(self)
//        mediaClient = nil
//
//    }
//
//    func sessionManager(_: GCKSessionManager, didStart session: GCKCastSession) {
//      attach(to: session)
//    }
//
//    func sessionManager(_: GCKSessionManager, didSuspend _: GCKCastSession,
//                        with _: GCKConnectionSuspendReason) {
//      detachFromCastSession()
//    }
//
//    func sessionManager(_: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
//      attach(to: session)
//    }
//
//    func sessionManager(_: GCKSessionManager, willEnd _: GCKCastSession) {
//      detachFromCastSession()
//    }
//
//}
//
//extension GoogleCastManager: GCKLoggerDelegate {
//
//    func logMessage(_ message: String,
//                    at level: GCKLoggerLevel,
//                    fromFunction function: String,
//                    location: String) {
//        print(function + " - " + message)
//    }
//}
//
//
//extension GoogleCastManager: GCKRemoteMediaClientListener {
//
//    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
//        lastKnownPlayerState = mediaStatus?.playerState ?? .unknown
//        lastKnownStreamPosition = mediaStatus?.streamPosition ?? 0
//        if lastKnownPlayerState == .idle {
//            sessionStatus = .finishPlaying
//        }
//    }
//}
//
//
//extension GoogleCastManager {
//
//
//    // MARK: - Build Meta
//
//    func buildMediaInformationWith(title: String,
//                                   description: String,
//                                   duration: TimeInterval,
//                                   audioUrl: URL,
//                                   thumbnailUrl: String?) -> GCKMediaInformation {
//        let metadata = buildMetadataWith(
//            title: title,
//            description: description,
//            thumbnailUrl: thumbnailUrl
//        )
//
//        let builder = GCKMediaInformationBuilder(contentURL: audioUrl)
//        builder.contentID = audioUrl.absoluteString
//        builder.streamType = .buffered
//        builder.streamDuration = duration
//        builder.contentType = "audio/mp3"
//        builder.metadata = metadata
//        builder.mediaTracks = nil
//        builder.textTrackStyle = nil
//
//        return builder.build()
//    }
//
//    private func buildMetadataWith(title: String,
//                                   description: String,
//                                   thumbnailUrl: String?) -> GCKMediaMetadata {
//
//        let metadata = GCKMediaMetadata.init(metadataType: .musicTrack)
//        metadata.setString(title, forKey: kGCKMetadataKeyTitle)
//        metadata.setString(description, forKey: kGCKMetadataKeySubtitle)
//        if let thumbnailUrl = thumbnailUrl, let url = URL(string: thumbnailUrl) {
//            metadata.addImage(GCKImage.init(url: url, width: 480, height: 720))
//        }
//
//        return metadata
//    }
//
//    func startSelectedItemRemotely(_ mediaInfo: GCKMediaInformation, autoPlay: Bool,at time: TimeInterval, playbackRate: Float, completion: @escaping GCKRequestCompletion) {
//        DispatchQueue.main.async {
//            let options = GCKMediaLoadOptions()
//            options.playPosition = time
//            options.autoplay = autoPlay
//            options.playbackRate = playbackRate
//            let mediaClient = self.sessionManager.currentCastSession?.remoteMediaClient
//            if let request =  mediaClient?.loadMedia(mediaInfo, with: options) {
//                request.delegate = self
//                self.pendingRequests[request.requestID] = completion
//            } else {
//                completion(false)
//            }
//        }
//
//    }
//
//    func changePlaybackRate(_ rate: Float) {
//        DispatchQueue.main.async {
//            let castSession = self.sessionManager.currentCastSession
//            if castSession != nil {
//                let remoteClient = castSession?.remoteMediaClient
//                remoteClient?.setPlaybackRate(rate)
//
//            }
//        }
//    }
//
//    // MARK: - Play/Resume
//
//    func playSelectedItemRemotely(to time: TimeInterval?, completion: @escaping GCKRequestCompletion) {
//        DispatchQueue.main.async {
//            let castSession = self.sessionManager.currentCastSession
//            if castSession != nil {
//                let remoteClient = castSession?.remoteMediaClient
//                if let time = time {
//                    let options = GCKMediaSeekOptions()
//                    options.interval = time
//                    options.resumeState = .play
//                    if let req = remoteClient?.seek(with: options) {
//                        req.delegate = self
//                        self.pendingRequests[req.requestID] = completion
//                    }
//                } else {
//                    if let req = remoteClient?.play(){
//                        req.delegate = self
//                        self.pendingRequests[req.requestID] = completion
//                    }
//
//                }
//            } else {
//                completion(false)
//            }
//        }
//
//    }
//
//    // MARK: - Pause
//
//    func pauseSelectedItemRemotely(to time: TimeInterval?, completion: @escaping GCKRequestCompletion) {
//        DispatchQueue.main.async {
//            let castSession = self.sessionManager.currentCastSession
//            if castSession != nil {
//                let remoteClient = castSession?.remoteMediaClient
//                if let time = time {
//                    let options = GCKMediaSeekOptions()
//                    options.interval = time
//                    options.resumeState = .pause
//                    if let req = remoteClient?.seek(with: options) {
//                        req.delegate = self
//                        self.pendingRequests[req.requestID] = completion
//                    }
//
//                } else {
//                    if let req = remoteClient?.pause() {
//                        req.delegate = self
//                        self.pendingRequests[req.requestID] = completion
//                    }
//
//                }
//            } else {
//                completion(false)
//            }
//        }
//
//    }
//
//    // MARK: - Update Current Time
//
//    func getSessionCurrentTime( completion: @escaping (TimeInterval?) -> Void) {
//        DispatchQueue.main.async {
//            guard self.pendingRequests.isEmpty else {
//                completion(nil)
//                return
//            }
//            let castSession = self.sessionManager.currentCastSession
//            if castSession != nil {
//                let remoteClient = castSession?.remoteMediaClient
//                let currentTime = remoteClient?.approximateStreamPosition()
//                completion(currentTime)
//            } else {
//                completion(nil)
//            }
//        }
//
//    }
//
//    // MARK: - Buffering status
//
//    func getMediaPlayerState(completion: @escaping (GCKMediaPlayerState) -> Void) {
//        DispatchQueue.main.async {
//            if let castSession = self.sessionManager.currentCastSession,
//               let remoteClient = castSession.remoteMediaClient,
//               let mediaStatus = remoteClient.mediaStatus {
//                completion(mediaStatus.playerState)
//            }
//
//            completion(GCKMediaPlayerState.unknown)
//        }
//
//    }
//
//}
//
//extension GoogleCastManager: GCKRequestDelegate {
//
//    func requestDidComplete(_ request: GCKRequest) {
//
//        if let completion = self.pendingRequests[request.requestID] {
//            completion(true)
//        }
//        self.pendingRequests.removeValue(forKey: request.requestID)
//    }
//
//    func request(_ request: GCKRequest, didFailWithError error: GCKError) {
//        if let completion = self.pendingRequests[request.requestID] {
//            completion(false)
//        }
//        self.pendingRequests.removeValue(forKey: request.requestID)
//    }
//
//    func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
//        if let completion = self.pendingRequests[request.requestID] {
//            completion(false)
//        }
//        self.pendingRequests.removeValue(forKey: request.requestID)
//    }
//}
