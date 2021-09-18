//
//  HomeClipsListModels.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

enum HomeClipsListModels {
    // MARK: Use cases
    
    enum Something {
        struct Request {
        }
        struct Response {
        }
        struct ViewModel {
        }
    }
    
    enum HomeClips {
        struct Request {
            let page: Int
            let per: Int
        }
        struct Response {
            let homeClips: AudioBoomClipBase
            let error: Error?
        }
        struct ViewModel {
            let homeClips: AudioBoomClipBase
            let errorDescription: String?
        }
    }
}


enum CollectionDetail {
    // MARK: Use cases
    
    enum Clips {
        struct Request {
            let collection: Collection?
        }
        struct Response {
            let clips: [AudioClip]?
            let error: String?
        }
        struct ViewModel {
            let clips: [AudioClip]
        }
    }
    
    enum PlayClips {
        struct Request {
            let clips: [AudioClip]
            let startClip: Clip?
            let endClip: Clip?
            let upcomingClips: [AudioClip]
            let isTimeslot: Bool
            let timeslotAd: AdClip?
        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }
    
    enum QueueClips {
        struct Request {
            let clips: [AudioClip]
        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }

    enum TimeSlot {
        struct Request {
            let timeLimitMinutes: Int
        }
        struct Response {
            let clips: [AudioClip]?
            let error: Error?
        }
        struct ViewModel {
            let clips: [AudioClip]
            let errorDescription: String?
        }
    }
    
    enum Options {
        case cancel
        case shareAll
        case shareTimeslot
        case shareClip
        case addClipToPlayQueue
        case addClipsToPlayQueue
    }
    
}

