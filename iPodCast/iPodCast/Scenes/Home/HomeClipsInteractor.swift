//
//  HomeClipsInteractor.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

protocol HomeClipsBusinessLogic {
    func fetchHomeClips(request: HomeClipsListModels.HomeClips.Request)
    func playHomeClips(request: CollectionDetail.PlayClips.Request)
}

protocol HomeClipsDataStore {
    //var name: String { get set }
}

class HomeClipsInteractor: HomeClipsBusinessLogic, HomeClipsDataStore {
  
    
    var presenter: HomeClipsPresentationLogic?
    var worker: HomeClipsWorker?
    
    private var homeClips: [Clip] = []
    
    // MARK: Do something
    
    func fetchHomeClips(request: HomeClipsListModels.HomeClips.Request) {
       
        let endpoint = APIEndpoint(rawValue: "/audio_clips")
        
        let apiRequest = APIRequest(endpoint: endpoint, method: .get, isCacheAllowed: false, parameters: nil)
        APIManager.shared.callAPI(of: [Clip].self, decoder: .istiakCast, withRequest: apiRequest) { (result) in
            switch result {
            case .success(let clips):
                
                if request.page == 0 {
                    self.homeClips.removeAll()
                }
                
                self.homeClips += clips
                let response = HomeClipsListModels.HomeClips.Response(homeClips: self.homeClips, error: nil)
                self.presenter?.presentHomeClips(response: response)
                
            case .failure(let error):
                let response = HomeClipsListModels.HomeClips.Response(homeClips: self.homeClips, error: error)
                self.presenter?.presentHomeClips(response: response)
            }
        }
    }
    
    func playHomeClips(request: CollectionDetail.PlayClips.Request) {
        // Play the clips
        IstiakPlayerManager.shared.play(withClips: request.clips, startClip: nil, endClip: nil, isTimeSlot: false, overwrite: true)
        //adjust playback speed
        IstiakPlayerManager.shared.changePlaybackSpeed(atRate: IstiakPlayerManager.shared.getCurrentPlaybackSpeed())
    }
}
