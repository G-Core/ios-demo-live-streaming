import UIKit

final class MainController: UITabBarController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = .white
        
        let strokeView = UIView()
        strokeView.translatesAutoresizingMaskIntoConstraints = false
        strokeView.backgroundColor = .grey800
        tabBar.addSubview(strokeView)
        tabBar.tintColor = .red
        
        NSLayoutConstraint.activate([
            strokeView.widthAnchor.constraint(equalToConstant: ScreenSize.width),
            strokeView.heightAnchor.constraint(equalToConstant: 1),
            strokeView.topAnchor.constraint(equalTo: tabBar.topAnchor),
        ])
        
        let viewingVC = ViewingController()
        viewingVC.tabBarItem = .init(
            title: "Viewing",
            image: .videosIcon, 
            selectedImage: .videosSelectedIcon
        )
        
        let streamingVC = StreamingController()
        let streamingNavVC = StreamingNavigationController(rootViewController: streamingVC)
        streamingNavVC.tabBarItem = .init(
            title: "Streaming",
            image: .signalIcon, 
            selectedImage: .signalSelectedIcon
        )

        let profileVC = ProfileController()
        profileVC.tabBarItem = .init(
            title: "Account",
            image: .accountIcon, 
            selectedImage: .accountSelectedIcon.withRenderingMode(.alwaysOriginal)
        )

        viewControllers = [viewingVC, streamingNavVC, profileVC]
    }   
}
