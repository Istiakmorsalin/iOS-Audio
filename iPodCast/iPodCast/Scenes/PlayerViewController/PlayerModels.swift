
import UIKit

enum Player {
    // MARK: Use cases
    
    enum Something {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum ProviderClips {
        struct Request {
            let providerId: Int
        }
        struct Response {
            let clips: [AudioClip]?
            let error: APIError?
        }
        struct ViewModel {
            let clips: [AudioClip]?
            let error: APIError?
        }
    }
    
    enum LinkedClip {
        struct Request {
            let linkedAudioClipId: Int
        }
        struct Response {
            let error: APIError?
        }
        struct ViewModel {
            let error: APIError?
        }
    }

}
