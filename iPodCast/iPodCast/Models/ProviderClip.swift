

import UIKit
import Kingfisher

class ProviderClip: Clip {
    var logo: String?
    var collection: Collection?
    
    init(id: Int, title: String, uri: String, logo: String?, collection: Collection?) {
        super.init(id: id, title: title, uri: uri)
        self.logo = logo
        self.collection = collection
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    func getArtwork(_ handler: @escaping (UIImage?) -> Void) {
        
        // Download the image artwork from the provider
        guard let url = URL(string: logo ?? "") else { return }
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
