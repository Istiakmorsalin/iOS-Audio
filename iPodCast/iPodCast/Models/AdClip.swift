
import UIKit
import Kingfisher

class AdClip: Clip {

    var providerID: Int?
    var providerLogo: String?
    var providerName: String?
    var updatedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case providerID // = "provider_id"
        case providerLogo // = "provider_logo"
        case providerName // = "provider_name"
        case updatedAt // = "updated_at"
    }

    // MARK: Encode object
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(providerID, forKey: .providerID)
        try container.encode(providerLogo, forKey: .providerLogo)
        try container.encode(providerName, forKey: .providerName)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    // MARK: Decode object
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        providerID = try values.decodeIfPresent(Int.self, forKey: .providerID)
        providerLogo = try values.decodeIfPresent(String.self, forKey: .providerLogo)
        providerName = try values.decodeIfPresent(String.self, forKey: .providerName)
        
        updatedAt = try values.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
    
    override init(id: Int, title: String, uri: String) {
        super.init(id: id, title: title, uri: uri)
    }
    
    func getArtwork(_ handler: @escaping (UIImage?) -> Void) {
        
        // Download the image artwork from the provider
        guard let url = URL(string: providerLogo ?? "") else { return }
        ImageDownloader.default.downloadImage(with: url, options: .none, completionHandler:  { (result) in
            switch result {
            case .success(let value):
                handler(value.image)
            case .failure(let error):
                debugPrint(error)
            }
        })
        
    }
    
}

