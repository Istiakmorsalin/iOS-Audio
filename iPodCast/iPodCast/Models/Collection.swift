

import UIKit

struct Collection: Codable {
    let id: Int
    let title: String
    let image: String
    let detailedImage: String?
    let category: Category?
    let updatedAt: String?
    let clipsMeta: ClipsMeta?
    let color: String?
    let imageProvider: String?
    var isListened: Bool = false
    let startClip: Clip?
    let endClip: Clip?
    var isPremium: Bool? = false
    
    var updatedAtDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard
            let updatedAt = updatedAt,
            let date = dateFormatter.date(from: updatedAt)
            else {
                return Date()
        }
        return date
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, title, image, category, clipsMeta, color, updatedAt, imageProvider, isPremium
        case startClip, endClip, detailedImage
    }
    
}
