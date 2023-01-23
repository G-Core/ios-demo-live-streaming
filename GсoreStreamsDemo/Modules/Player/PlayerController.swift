import Foundation
import AVKit

final class PlayerController: AVPlayerViewController {
    var url: URL?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = url else {
            print("url is nil") 
            dismiss(animated: false)
            return
        }
        print(url)
        player = AVPlayer(url: url)
        player?.play()
    }
}
