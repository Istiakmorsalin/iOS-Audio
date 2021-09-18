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
    func playFavoriteClips(request: CollectionDetail.PlayClips.Request)
}

protocol HomeClipsDataStore {
    //var name: String { get set }
}

class HomeClipsInteractor: HomeClipsBusinessLogic, HomeClipsDataStore {
  
    
    var presenter: HomeClipsPresentationLogic?
    var worker: HomeClipsWorker?
    
    private var homeClips: [Audio_clips] = []
    
    // MARK: Do something
    
    func fetchHomeClips(request: HomeClipsListModels.HomeClips.Request) {
       
        let endpoint = APIEndpoint(rawValue: "audio_clips")
        
        let apiRequest = APIRequest(endpoint: endpoint, method: .get, isCacheAllowed: false, parameters: nil, excludeAuth: true)
        APIManager.shared.callAPI(of: AudioBoomClipBase.self, decoder: .istiakCast, withRequest: apiRequest) { (result) in
            switch result {
            case .success(let clips):
                let response = HomeClipsListModels.HomeClips.Response(homeClips: clips, error: nil)
                self.presenter?.presentHomeClips(response: response)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func playHomeClips(request: CollectionDetail.PlayClips.Request) {
        // Play the clips
        IstiakPlayerManager.shared.play(withClips: request.clips, startClip: nil, endClip: nil, isTimeSlot: false, overwrite: true)
        //adjust playback speed
        IstiakPlayerManager.shared.changePlaybackSpeed(atRate: IstiakPlayerManager.shared.getCurrentPlaybackSpeed())
    }
    
    func playFavoriteClips(request: CollectionDetail.PlayClips.Request) {
        
        // Play the clips
        IstiakPlayerManager.shared.play(withClips: request.clips, startClip: nil, endClip: nil, isTimeSlot: false, overwrite: true)
        //adjust playback speed
        IstiakPlayerManager.shared.changePlaybackSpeed(atRate: IstiakPlayerManager.shared.getCurrentPlaybackSpeed())
    }
}
