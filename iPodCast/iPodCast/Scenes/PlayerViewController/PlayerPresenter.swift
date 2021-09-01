import UIKit

protocol PlayerPresentationLogic {
    func presentSomething(response: Player.Something.Response)
    func presentLinkedClip(response: Player.LinkedClip.Response)
}

class PlayerPresenter: PlayerPresentationLogic {
    weak var viewController: PlayerDisplayLogic?
    
    // MARK: Do something
    
    func presentSomething(response: Player.Something.Response) {
        let viewModel = Player.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
    
    func presentLinkedClip(response: Player.LinkedClip.Response) {
        let viewModel = Player.LinkedClip.ViewModel(error: response.error)
        viewController?.displayLinkedClip(viewModel: viewModel)
    }
}
