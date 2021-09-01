//
//  SigninViewController.swift
//  IstiakCast
//
//  Created by Istiak Morsalin on 1/9/21.
//

import UIKit
import SwiftUI

struct SigninViewControllerRepresentation: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<SigninViewControllerRepresentation>) -> SigninViewController {
        UIStoryboard(name: "SigninViewController", bundle: nil).instantiateViewController(withIdentifier: "SigninViewController") as! SigninViewController
    }

    func updateUIViewController(_ uiViewController: SigninViewController, context: UIViewControllerRepresentableContext<SigninViewControllerRepresentation>) {
    }
}


class SigninViewController: UIViewController {
    
    @IBOutlet weak var loginWithGoogleButton: UIButton!

   
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    @IBAction func loginWithGoogleTapped(_ sender: Any) {
        let swiftUIView = HomeView() // swiftUIView is View
        let viewCtrl = UIHostingController(rootView: swiftUIView)
        self.present(viewCtrl, animated: true, completion: nil)
    }
    private func setup() {
//        let viewController = self
    }

    
    
    @objc private func loginButtonTapped() {
    
    }
    
    
}
