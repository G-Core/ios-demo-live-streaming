import UIKit
import HaishinKit

final class StreamCaptureController: UIViewController {
    // MARK: - Public properties
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .all
    }

    var stream: Stream? {
        get { rtmpManager.stream }
        set { rtmpManager.stream = newValue }
    }

    // MARK: - Private properties
    private let captureView = StreamCaptureView()
    private let rtmpManager = RTMPStreamManager()

    // MARK: - Life cycle
    override func loadView() {
       view = captureView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        captureView.attachStream(rtmpManager.rtmpStream)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true

        navigationController?.navigationBar.isHidden = true
        navigationController?.setStatusBar(backgroundColor: .grey800 ?? .black)
        navigationController?.navigationBar.barStyle = .black
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    // MARK: - Private methods
    @inline(__always)
    private func setupView() {
        rtmpManager.delegate = self
        captureView.delegate = self
    }
}

// MARK: - RTMPStreamManagerDelegate
extension StreamCaptureController: RTMPStreamManagerDelegate {
    func streamStaticDidChange(currentFPS: UInt16, currentBytesOutPerSecond: Int32) {
        captureView.setVideoData(fps: Int(currentFPS), bitrate: Int(currentBytesOutPerSecond))
    }
}

// MARK: - StreamCaptureViewDelegate
extension StreamCaptureController: StreamCaptureViewDelegate {
    func dismiss() {
        rtmpManager.close()
        tabBarController?.tabBar.isHidden = false
        navigationController?.setStatusBar(backgroundColor: .white)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.popViewController(animated: true)
    }

    func flipCamera() {
        rtmpManager.flipCamera { error in
            if let error = error {
                print(error.description)
            }
        }
    }
    
    func showSettings() {
        let vc =  StreamSettingsController()
        vc.loadViewIfNeeded()

        vc.configure(
            currentSettings: (rtmpManager.urlType, rtmpManager.videoType),
            urlSelectHandler: { [weak self] type in
                print(type.rawValue)
                self?.rtmpManager.urlType = type
            },
            qualitySelectHandler: { [weak self] type in
                print(type.description)
                self?.rtmpManager.videoType = type
            }
        )

        let navVC = StreamSettingsNavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func toggleStartStream(isOn: Bool, handler: (Bool) -> Void) {
        if isOn {
            navigationController?.setStatusBar(backgroundColor: .grey800 ?? .black)
            rtmpManager.start()
            rtmpManager.play()
        } else {
            navigationController?.setStatusBar(backgroundColor: .clear)
            rtmpManager.close()
        }

        handler(true)
    }
    
    func toggleMuteMicro(isOn: Bool, handler: (Bool) -> Void) {
        rtmpManager.toggleMic(isOn: isOn)
        handler(true)
    }
    
    func togglePlay(isOn: Bool, handler: (Bool) -> Void) {
        isOn ? (rtmpManager.play()) : (rtmpManager.pause())
        handler(true)
    }
}
