
import UIKit

protocol PlayerRoutingLogic {
   
}

protocol PlayerDataPassing {
    var dataStore: PlayerDataStore? { get }
}

class PlayerRouter: NSObject, PlayerRoutingLogic, PlayerDataPassing {
    weak var viewController: PlayerViewController?
    var dataStore: PlayerDataStore?

    
    // MARK: Navigation
    
}
