
import UIKit
import Cashier

struct ListenedClip: Codable, Equatable {
    let id: Int
}

class IstiakPlayerWorker {
    
    static let shared = IstiakPlayerWorker()
    
    private var cache: Cashier! {
        let cache = NOPersistentStore.cache(withId: "\(IstiakPlayerWorker.self)")
        cache?.persistent = true
        return cache
    }
    
    init() {

        // MARK: List of all the collections listened through
        if let raw = cache.data(forKey: Keys.listenedCollections),
            let data = try? JSONDecoder().decode([Int].self, from: raw) {
            listenedCollections = Array(data.prefix(50))
        }
        
        // MARK: List of all the clips listened through
        if let raw = cache.data(forKey: Keys.listenedClips),
            let data = try? JSONDecoder().decode([ListenedClip].self, from: raw) {
            listenedClips = Array(data.prefix(300))
        }
        
        // MARK: Progress of the clips - Key: clip.id, Value: seconds
        if let raw = cache.data(forKey: Keys.clipsProgress),
            let data = try? JSONDecoder().decode([Int:Int].self, from: raw) {
            clipProgress = data
        }
        
    }
    
    private var listenedCollections: [Int] = []
    private var listenedClips: [ListenedClip] = []
    private var clipProgress: [Int:Int] = [:]

    public func saveProgress(withSeconds seconds: Int, withClip id: Int) {
        clipProgress[id] = seconds

        // Save the clip progress
        guard let encoded = try? JSONEncoder().encode(clipProgress) else { return }
        cache.setData(encoded, forKey: Keys.clipsProgress)
    }
    
    public func removeClipProgress(withClip id: Int) {
        clipProgress.removeValue(forKey: id)
        
        // Save the clip progress
        guard let encoded = try? JSONEncoder().encode(clipProgress) else { return }
        cache.setData(encoded, forKey: Keys.clipsProgress)
    }
    
    public func saveListenedTo(withClip clip: ListenedClip) {
        clipProgress.removeValue(forKey: clip.id)
        guard !listenedClips.contains(clip) else { return }
        listenedClips.append(clip)

        // Save the listened to clip array
        guard let encoded = try? JSONEncoder().encode(listenedClips) else { return }
        cache.setData(encoded, forKey: Keys.listenedClips)
    }
    
//    public func saveListenedTo(withCollection id: Int) {
//        guard !listenedCollections.contains(id) else { return }
//        listenedCollections.append(id)
//
//        // Save the listened collections array
//        guard let encoded = try? JSONEncoder().encode(listenedCollections) else { return }
//        cache.setData(encoded, forKey: Keys.listenedCollections)
//    }
    
    public func getListenedCollections() -> [Int] {
        return listenedCollections
    }
    
    public func getListenedToClips() -> [ListenedClip] {
        return listenedClips
    }
    
    public func getProgress(forClip id: Int) -> Int {
        return clipProgress[id] ?? 0
    }
    
    public func resetUserPreferences() {
        listenedClips.removeAll()
        listenedCollections.removeAll()
        clipProgress.removeAll()
        
        // Save the clip progress
        guard let encoded = try? JSONEncoder().encode(clipProgress) else { return }
        cache.setData(encoded, forKey: Keys.clipsProgress)
        
        // Save the listened to clip array
        guard let encoded1 = try? JSONEncoder().encode(listenedClips) else { return }
        cache.setData(encoded1, forKey: Keys.listenedClips)
        
        // Save the listened to clip array
        guard let encoded2 = try? JSONEncoder().encode(listenedClips) else { return }
        cache.setData(encoded2, forKey: Keys.listenedClips)
    }

}


// MARK: - Keys

extension IstiakPlayerWorker {
    private struct Keys {
        static let listenedClips = "listenedClips"
        static let listenedCollections = "listenedCollections"
        static let clipsProgress = "clipsProgress"
    }
}

extension Notification.Name {
    
    // LTNPlayer
    static var initial: Notification.Name {  return .init(rawValue: "LTNPlayer.initial") }
    static var isBuffering: Notification.Name { return .init(rawValue: "LTNPlayer.isBuffering") }
    static var isPlaying: Notification.Name { return .init(rawValue: "LTNPlayer.isPlaying") }
    static var isPaused: Notification.Name { return .init(rawValue: "LTNPlayer.isPaused") }
    static var isFinished: Notification.Name { return .init(rawValue: "LTNPlayer.isFinished") }
    static var addedToQueue: Notification.Name { return .init(rawValue: "LTNPlayer.addedToQueue") }
    
    static var didChangeTimeslotLimit: Notification.Name { return .init(rawValue: "didChangeTimeslotLimit") }
    static var changeSpeed: Notification.Name { return .init(rawValue: "LTNPlayer.changeSpeed") }
    
}

enum IstiakPlayerState {
    case initial
    case isBuffering
    case isPlaying
    case isPaused
    case isFinished
}

enum IstiakPlayerType {
    case local
    case chromeCast
}
