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
            let homeClips: [Clip]
            let error: Error?
        }
        struct ViewModel {
            let homeClips: [Clip]
            let errorDescription: String?
        }
    }
}

