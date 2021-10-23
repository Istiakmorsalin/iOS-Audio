

import UIKit

struct Category: Codable {
    let id: Int
    let name: String?
    var identifier: String?
    let color: String?
    let image: String?
    var subscribed: Bool?
    var description: String?
}
