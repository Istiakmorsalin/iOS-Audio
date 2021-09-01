import Foundation
import UIKit

public extension UIViewController {

    func addDrawerView(withViewController viewController: UIViewController, parentView: UIView? = nil) -> DrawerView {
        // self.addChild(viewController) - [IMPORTANT] This line makes the player view controller go into the tabbar.
        let drawer = DrawerView(withView: viewController.view)
        drawer.attachTo(view: self.view)
        return drawer
    }
    
}


