
import UIKit

protocol PlayerBusinessLogic {
    func doSomething(request: Player.Something.Request)
    func playLinkedClip(request: Player.LinkedClip.Request)
}

protocol PlayerDataStore {
    //var name: String { get set }
}

class PlayerInteractor: PlayerBusinessLogic, PlayerDataStore {
    var presenter: PlayerPresentationLogic?
    var worker: PlayerWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func doSomething(request: Player.Something.Request) {
        worker = PlayerWorker()
        worker?.doSomeWork()
        
        let response = Player.Something.Response()
        presenter?.presentSomething(response: response)
    }
    
    func playLinkedClip(request: Player.LinkedClip.Request) {
        
    let apiRequest = APIRequest(endpoint: APIEndpoint(rawValue: "/api/v4/audio_clips/\(request.linkedAudioClipId)"), method: .get, isCacheAllowed: false, parameters: nil)
        
        APIManager.shared.callAPI(of: AudioClip.self, decoder: JSONDecoder.istiakCast, withRequest: apiRequest) { [weak self] (result) in
            switch result {
            case .success(let audioClip):

                // This is a hack. We need to remove the providerID, since it will play a provider clip if passed on.
                audioClip.provider?.id = -1
                
                // Play these clips
                IstiakPlayerManager.shared.play(withClips: [audioClip] + IstiakPlayerManager.shared.queue, startClip: nil, endClip: nil, isTimeSlot: false, overwrite: true)

                let response = Player.LinkedClip.Response(error: nil)
                self?.presenter?.presentLinkedClip(response: response)
                
            case .failure(let error):
                let response = Player.LinkedClip.Response(error: error)
                self?.presenter?.presentLinkedClip(response: response)
            }
        }
    }
}
