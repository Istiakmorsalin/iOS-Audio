

import UIKit

class EditorClip: Clip {
    
    var groupId: Int?
    
    // MARK: Encode object
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupId, forKey: .groupId)
    }
    
    // MARK: Decode object
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        groupId = try values.decodeIfPresent(Int.self, forKey: .groupId)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case groupId
    }
}
