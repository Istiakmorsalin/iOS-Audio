

import UIKit

// MARK: - ClipsMeta
struct ClipsMeta: Codable {

    struct Total: Codable {

        struct Duration: Codable {
            let millisecond: Int
            let formatted: String
        }

        let count: Int
        let duration: Duration
        
    }
    
    struct New: Codable {
        let count: Int?
    }
    
    let total: Total
    let new: New?
}
