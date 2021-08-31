

import Foundation

struct Logo: Codable {
    let url: String?
    
    init(url: String?) {
        self.url = url
    }
}
