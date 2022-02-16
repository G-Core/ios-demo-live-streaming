//
//  GCTabBarController.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 15.10.2021.
//

import UIKit

final class GCTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        
        viewControllers = [
            GCAccountViewController(),
            GCBroadcastListViewController(),
            GCRecordViewController()
        ]
        
        viewControllers?[0].tabBarItem = UITabBarItem(title: NSLocalizedString("Account", comment: ""),
                                                      image: .adjustmentImage,
                                                      selectedImage: nil)
        
        viewControllers?[1].tabBarItem = UITabBarItem(title: NSLocalizedString("Broadcast", comment: ""),
                                                      image: .broadcastImage,
                                                      selectedImage: nil)
        
        viewControllers?[2].tabBarItem = UITabBarItem(title: NSLocalizedString("Stream", comment: ""),
                                                      image: .streamImage,
                                                      selectedImage: nil)
    }
}
