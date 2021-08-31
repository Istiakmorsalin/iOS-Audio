

import UIKit
import Kingfisher

class AudioClip: Clip {
    
    var language: Language?
    var provider: Provider?
    var linkedAudioClipID: Int?
    var hostAndSpeakingInfo: String?
    var tags: [String]?
    var category: Category?
    var collectionTitle: String?
    
    var playbackStart: Int?
    var playbackEnd: Int?
    
    var providerClip: ProviderClip? = nil
    var collectionIds: [Int]?
    var isTimeslot: Bool?
    var isPremium: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, title, hostAndSpeakingInfo
        case type
        case provider
        case linkedAudioClipID = "linkedAudioClipId"
        case tags, category
        case playbackStart, playbackEnd
        case isPremium
        case language
        case collectionIds
    }
    
    var infoString: String {
        guard let provider = provider?.name else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return "\(String(describing: provider)) •  \(durationString)"
    }
    
    var durationString: String {
        let (hours, minutes, seconds) = self.hmsFrom(seconds: durationTimeSeconds)
        let secondsString = self.getStringFrom(seconds: seconds)
        let minutesString = self.getStringFrom(seconds: minutes)
        let hoursString = self.getStringFrom(seconds: hours)
        
        if hours > 0 {
            return "\(hoursString):\(minutesString):\(secondsString)"
        } else {
            return "\(minutesString):\(secondsString)"
        }
    }
    
    private func hmsFrom(seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func getStringFrom(seconds: Int) -> String {
           return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    override init(id: Int, title: String, uri: String) {
        super.init(id: id, title: title, uri: uri)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
    
    // MARK: Decode object
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        playbackStart = try values.decodeIfPresent(Int.self, forKey: .playbackStart)
        playbackEnd = try values.decodeIfPresent(Int.self, forKey: .playbackEnd)
        provider = try values.decodeIfPresent(Provider.self, forKey: .provider)
        linkedAudioClipID = try values.decodeIfPresent(Int.self, forKey: .linkedAudioClipID)
        tags = try values.decodeIfPresent([String].self, forKey: .tags)
        category = try values.decodeIfPresent(Category.self, forKey: .category)
        isPremium = try values.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        language = try values.decodeIfPresent(Language.self, forKey: .language)
        hostAndSpeakingInfo = try values.decodeIfPresent(String.self, forKey: .hostAndSpeakingInfo)
        collectionIds = try values.decodeIfPresent([Int].self, forKey: .collectionIds)
    }
    
    func getArtwork(_ handler: @escaping (UIImage?) -> Void) {
        
        // Download the image artwork from the provider
        guard let url = URL(string: provider?.logo?.url ?? "") else { return }
        ImageDownloader.default.downloadImage(with: url, options: nil, completionHandler:  { (result) in
            switch result {
            case .success(let value):
                handler(value.image)
            case .failure(let error):
                debugPrint(error)
            }
        })
        
    }
}
