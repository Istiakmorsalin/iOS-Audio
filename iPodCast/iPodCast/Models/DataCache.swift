
struct DataCache: Codable {
    
    var categories: [Category] = []
    var providers: [Provider] = []
    var languages: [Language] = []
    var jingleAudioClipUrl: String = ""
    var adAudioClips: [AdClip] = []
    var playAdAfterClips: Int = 8
    var maxContentGroupsFetchAtOnce: Int = 0
    
    init(from decoder: Decoder) throws {
        let map = try decoder.container(keyedBy: CodingKeys.self)
        self.categories = try map.decode([Category].self, forKey: .categories)
        self.providers = try map.decode([Provider].self, forKey: .providers)
        self.languages = try map.decode([Language].self, forKey: .languages)
        self.jingleAudioClipUrl = try map.decode(String.self, forKey: .jingleAudioClipUrl)
        self.playAdAfterClips = try map.decode(Int.self, forKey: .playAdAfterClips)
        self.adAudioClips = try map.decode([AdClip].self, forKey: .adAudioClips)
        self.maxContentGroupsFetchAtOnce = try map.decode(Int.self, forKey: .maxContentGroupsFetchAtOnce)
    }
    
    private enum CodingKeys: String, CodingKey {
        case languages, categories, providers
        case jingleAudioClipUrl = "uri"
        case adAudioClips // = "ad_audio_clips"
        case playAdAfterClips //= "play_ad_after_clips"
        case maxContentGroupsFetchAtOnce
    }
    
}

struct Language: Codable {
    let name: String
    let iso6391: String?
    let flag: String?
    let isoCountryCode: String?
    var subscribed: Bool?
}

struct EmptyAPIResponse: Codable { }
