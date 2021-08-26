//
//  HomeSceneView.swift
//  IstiakCast
//
//  Created by ISTIAK on 26/8/21.
//

import SwiftUI
import UIKit

struct HomeViewScene: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> HomeViewController {
        let homeScene = HomeViewController()
        return homeScene
    }
    
    func updateUIViewController(_ uiViewController: HomeViewController, context: Context) {
    }
    
    typealias UIViewControllerType = HomeViewController
}
