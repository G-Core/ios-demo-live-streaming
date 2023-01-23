//
//  AppDelegate.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 15.10.2021.
//

import UIKit
import AVFoundation

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupSession()

        window = UIWindow(frame: UIScreen.main.bounds)

        if Settings.shared.accessToken != nil {
            window?.rootViewController = MainController()
        } else {
            window?.rootViewController = LoginViewController()
        }

        window?.makeKeyAndVisible()

        if #available(iOS 13, *) {
            window?.overrideUserInterfaceStyle = .light
        }

        return true
    }
    
    //Setting up a session for haishinKit
    private func setupSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
}

