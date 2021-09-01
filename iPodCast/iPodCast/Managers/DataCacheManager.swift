
import UIKit
import Cashier

class DataCacheManager {

    static let shared = DataCacheManager()
    
    private var cache: Cashier! {
        let cache = NOPersistentStore.cache(withId: "\(DataCacheManager.self)")
        cache?.persistent = true
        return cache
    }
    
    // MARK: Ads
    
    /// Specifies how many content groups should be displayed on home
    var maxContentGroups: Int? {
        get {
            return cache?.object(forKey: Keys.maxContentGroups) as? Int
        }
        set {
            if let value = newValue {
                cache?.setObject(value, forKey: Keys.maxContentGroups)
            } else {
                cache?.deleteObject(forKey: Keys.maxContentGroups)
            }
        }
    }
    
    /// Specifies how ofter should ads be played. A value of 1 will play an ad after each clip
    var adFrequency: Int? {
        get {
            return cache?.object(forKey: Keys.adFrequency) as? Int
        }
        set {
            if let value = newValue {
                cache?.setObject(value, forKey: Keys.adFrequency)
            } else {
                cache?.deleteObject(forKey: Keys.adFrequency)
            }
        }
    }
    
    var languages: [Language] {
        get {
            if
                let raw = cache.data(forKey: Keys.languages),
                let data = try? JSONDecoder().decode([Language].self, from: raw) {
                return data
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                cache.setData(encoded, forKey: Keys.languages)
            }
        }
    }
    
    var jingleURL: String? {
        get {
            return cache?.object(forKey: Keys.jingleURL) as? String
        }
        set {
            if let value = newValue {
                cache?.setObject(value, forKey: Keys.jingleURL)
            } else {
                cache?.deleteObject(forKey: Keys.jingleURL)
            }
        }
    }
    
    // all the ads available
    var ads: [AdClip] {
        get {
            if
                let raw = cache.data(forKey: Keys.ads),
                let data = try? JSONDecoder().decode([AdClip].self, from: raw)
            {
                return data
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                cache.setData(encoded, forKey: Keys.ads)
            }
        }
    }
    
    private var adsPlayed: Set<Int> {
        get {
            if
                let raw = cache.data(forKey: Keys.adsPlayed),
                let data = try? JSONDecoder().decode(Set<Int>.self, from: raw)
            {
                return data
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                cache.setData(encoded, forKey: Keys.adsPlayed)
            }
        }
    }
    
    var providers: [Provider] {
        get {
            if
                let raw = cache.data(forKey: Keys.providers),
                let data = try? JSONDecoder().decode([Provider].self, from: raw)
            {
                return data
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                cache.setData(encoded, forKey: Keys.providers)
            }
        }
    }
    
    var editorSpeaks: [EditorClip] {
        get {
            if
                let raw = cache.data(forKey: Keys.editorSpeaks),
                let data = try? JSONDecoder().decode([EditorClip].self, from: raw)
            {
                return data
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                cache.setData(encoded, forKey: Keys.editorSpeaks)
            }
        }
    }
    
    var sortedAdClips: [AdClip] {
        let ads = self.ads
        let adsPlayed = self.adsPlayed
        return ads.sorted(by: { a, _ in return !adsPlayed.contains(a.id)})
    }
    
    var radio24SyvProvider: Provider? {
        return providers.first(where: { $0.id == 67 })
    }
    
    func markClipAsListenedTo(withAdClip adClip: AdClip) {
        //remove ads played cache if all the ads in cache have been played
        checkAllAdsHaveBeenPlayed()
        
        // add the last played add
        var adsPlayed = self.adsPlayed
        adsPlayed.insert(adClip.id)
        self.adsPlayed = adsPlayed
    }
    
    private func checkAllAdsHaveBeenPlayed() {
        var adsPlayed = self.adsPlayed
        let count = ads.map({ adsPlayed.contains($0.id) }).filter({ $0 == true }).count
        if count == ads.count {
            adsPlayed.removeAll()
            self.adsPlayed = adsPlayed
        }
    }
}

// MARK: - Keys

extension DataCacheManager {
    private struct Keys {
        static let adFrequency = "playAdAfterClips"
        static let jingleURL = "jingleAudioClipUrl"
        static let providers = "providers"
        static let editorSpeaks = "editorSpeaks"
        static let ads = "ads"
        static let adsPlayed = "adsPlayed"
        static let maxContentGroups = "maxContentGroups"
        static let languages = "languages"
    }
}
