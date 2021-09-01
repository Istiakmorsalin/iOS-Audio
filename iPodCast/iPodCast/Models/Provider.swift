

import Foundation

struct Provider: Codable {
    var id: Int = 0
    var name: String = ""
    var uri: String?
    var logo: Logo?
    let isAdsAllowed: Bool
}

