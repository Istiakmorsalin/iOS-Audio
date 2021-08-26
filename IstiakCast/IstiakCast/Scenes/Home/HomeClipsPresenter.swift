//
//  HomeClipsPresenter.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//
import UIKit


protocol HomeClipsPresentationLogic {
    func presentHomeClips(response: HomeClipsListModels.HomeClips.Response)
}

class HomeClipsPresenter: HomeClipsPresentationLogic {
    weak var viewController: HomeViewControllerDisplayLogic?
    
    // MARK: Do something
    
    func presentHomeClips(response: HomeClipsListModels.HomeClips.Response) {
        let viewModel = HomeClipsListModels.HomeClips.ViewModel(homeClips: response.homeClips, errorDescription: response.error?.localizedDescription)
        viewController?.displayHomeClips(viewModel: viewModel)
    }
}
