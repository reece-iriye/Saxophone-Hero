
import UIKit

class LaunchViewController: UIViewController {
    override var shouldAutorotate: Bool {
        return true
    }
    
    // Adjusted to comply with the new iOS guidelines
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Request geometry update for landscape orientation
        if let windowScene = view.window?.windowScene {
            let orientationUpdate = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscape)
            windowScene.requestGeometryUpdate(orientationUpdate) { error in
                print(error.localizedDescription)
            }
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
}
