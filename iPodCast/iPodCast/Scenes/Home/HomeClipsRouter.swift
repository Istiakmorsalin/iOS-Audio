//
//  HomeClipsRouter.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

protocol HomeClipsRouterRoutingLogic {
    func navigateBack()
    func openMinimumPlayer()
}

protocol HomeClipsDataPassing {
    var dataStore: HomeClipsDataStore? { get }
}

class HomeClipsRouter: NSObject, HomeClipsRouterRoutingLogic, HomeClipsDataPassing {
    weak var viewController: HomeViewController?
    var dataStore: HomeClipsDataStore?
    
    // MARK: Navigation
    
    func navigateBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func openMinimumPlayer() {
        DispatchQueue.main.async {
//            guard let homeview = self.viewController as? HomeViewController else { return }
//            homeview.showPlayer(withPosition: .partiallyOpen)
        }
    }
}
