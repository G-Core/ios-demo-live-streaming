//
//  GCPlayerViewController.swift
//  G-CoreLabs_DemoOne
//
//  Created by Evgeniy Polyubin on 23.09.2021.
//

import Foundation
import AVKit

final class GCPlayerViewController: AVPlayerViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    convenience init(player: AVPlayer) {
        self.init()
        self.player = player
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player = nil
    }
}
