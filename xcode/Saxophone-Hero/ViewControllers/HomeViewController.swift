import UIKit


class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the background image view
        self.setUpBackgroundImage()
    }

    // This function sets up the background image view
    func setUpBackgroundImage() {
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: "home_image")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)

        // Adjust the frame of the imageView based on the actual image's aspect ratio
        if let imageSize = backgroundImageView.image?.size {
            let viewSize = backgroundImageView.bounds.size
            let widthRatio = viewSize.width / imageSize.width
            let heightRatio = viewSize.height / imageSize.height
            
            // Determine the middle ratio between widthRatio and heightRatio
            let middleRatio = (widthRatio + heightRatio) / 2
            
            // Scale the image by middleRatio
            let scaledImageWidth = imageSize.width * middleRatio
            let scaledImageHeight = imageSize.height * middleRatio
            
            // Center the image
            backgroundImageView.bounds.size = CGSize(
                width: scaledImageWidth,
                height: scaledImageHeight
            )
            backgroundImageView.center = CGPoint(
                x: viewSize.width/2,
                y: viewSize.height/2
            )
        }
    }

    // Lock the view controller in landscape mode
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

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

    // If the rest of your app is in portrait mode and you wish to return to it after this view controller disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let windowScene = view.window?.windowScene {
            let orientationUpdate = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(orientationUpdate) { error in
                print(error.localizedDescription)
            }
        }
    }
}

