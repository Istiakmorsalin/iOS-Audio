//
//  HomeClipsRouter.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import UIKit

protocol HomeClipsRouterRoutingLogic {
    func navigateBack()
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
}
