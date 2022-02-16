//
//  GCRecordViewController.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 27.10.2021.
//

import UIKit
import HaishinKit
import AVFoundation
import VideoToolbox
import Logboard

final class GCRecordViewController: UIViewController {
    private lazy var networkManager = NetworkManager(delegate: self)
    private var stream: GCStream?
    private var streamName: String { stream?.name ?? "Stream not chosen" }
    private var settingsVC: GCStreamSettingsController?
    private var rtmpStream: RTMPStream!
    private var rtmpConnection: RTMPConnection!
    private var attachedCamera = DeviceUtil.device(withPosition: .front)
    private var isLive = false
    private var sufficientBWCount = 0
    private var insufficientBWCount = 0
    
    var videoType: VideoSettings.VideoType = .hq {
        didSet {
            if videoType != oldValue {
                setupVideoSetting(type: videoType)
            }
        }
    }
    
    private let model = GCModel.shared
    private let hkView = HKView(frame: .zero)
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(.playImage, for: .normal)
        button.addTarget(self, action: #selector(tapPlayButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    private let configureButton: UIButton = {
        let button = UIButton()
        button.setImage(.gearshapeImage, for: .normal)
        button.addTarget(self, action: #selector(tapConfigureButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let flipButton: UIButton = {
        let button = UIButton()
        button.setImage(.flipIcon, for: .normal)
        button.addTarget(self, action: #selector(tapFlipButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let fpsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.text = "0 fps"
        label.textColor = .black
        return label
    }()
    
    private let bitrateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.text = "0 kbps"
        label.textColor = .black
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHaishinKit()
        setupVideoSetting(type: videoType)
        view.addSubview(playButton)
        view.addSubview(configureButton)
        view.addSubview(flipButton)
        view.addSubview(fpsLabel)
        view.addSubview(bitrateLabel)
        createConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        networkManager.token = model.accessToken
    }
    
    @objc private func tapPlayButton() {
        guard let stream = stream
        else { return }
        
        if playButton.image(for: .normal) == .playImage {
            
            if rtmpConnection.connected == false {
                rtmpConnection.connect(stream.connectString)
            }
            
            rtmpStream.publish(stream.publishString)
            rtmpStream.paused = false
            isLive = true
            playButton.setImage(.pauseImage, for: .normal)
            configureButton.isUserInteractionEnabled = false
            configureButton.alpha = 0.5
            tabBarController?.tabBar.isHidden = true
        } else {
            rtmpStream.paused = true
            isLive = false
            playButton.setImage(.playImage, for: .normal)
            configureButton.isUserInteractionEnabled = true
            configureButton.alpha = 1
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    @objc private func tapFlipButton() {
        let frontCamera = DeviceUtil.device(withPosition: .front)
        let backCamera = DeviceUtil.device(withPosition: .back)
        attachedCamera == frontCamera ? (attachedCamera = backCamera) : (attachedCamera = frontCamera)
        rtmpStream.attachCamera(attachedCamera)
    }
    
    @objc private func tapConfigureButton() {
        let vc = GCStreamSettingsController()
        settingsVC = vc
        vc.model = model
        vc.delegate = self
        addChild(vc)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.updateStreamName(streamName)
        
        NSLayoutConstraint.activate([
            vc.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            vc.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vc.view.heightAnchor.constraint(equalToConstant: view.frame.height / 2)
        ])
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            playButton.widthAnchor.constraint(equalToConstant: 30),
            playButton.heightAnchor.constraint(equalToConstant: 30),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
            
            configureButton.widthAnchor.constraint(equalToConstant: 30),
            configureButton.heightAnchor.constraint(equalToConstant: 30),
            configureButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            configureButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            
            flipButton.widthAnchor.constraint(equalToConstant: 30),
            flipButton.heightAnchor.constraint(equalToConstant: 30),
            flipButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            flipButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            
            fpsLabel.widthAnchor.constraint(equalToConstant: 80),
            fpsLabel.heightAnchor.constraint(equalToConstant: 30),
            fpsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            fpsLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            
            bitrateLabel.widthAnchor.constraint(equalToConstant: 80),
            bitrateLabel.heightAnchor.constraint(equalToConstant: 30),
            bitrateLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            bitrateLabel.topAnchor.constraint(equalTo: fpsLabel.bottomAnchor, constant: 10)
        ])
    }
    
    private func setupHaishinKit() {
        hkView.frame = view.bounds
        hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        hkView.backgroundColor = .black
        hkView.attachStream(newRTMPStream())
        view.addSubview(hkView)
    }
    
    private func pushErrorAllert(with error: HTTPError) {
        DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController.init(title: NSLocalizedString("Error!", comment: "") ,
                                               message: "",
                                               preferredStyle: .actionSheet)
            
            switch error {
            case .response(let text): alert.message = "\(text)"
            default: alert.message = NSLocalizedString("unexpected error.", comment: "")
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    //creating a new instance of the stream
    private func newRTMPStream() -> RTMPStream {
        self.rtmpConnection = RTMPConnection()
        let rtmpStream = RTMPStream(connection: rtmpConnection)
        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio))
        rtmpStream.attachCamera(attachedCamera)
        rtmpStream.delegate = self
        self.rtmpStream = rtmpStream
        StreamSettings.presetStreamFor(rtmpStream)
        return rtmpStream
    }
    
    //Updating video settings of the stream
    private func setupVideoSetting(type: VideoSettings.VideoType) {
        guard let rtmpStream = rtmpStream
        else { return }
        
        let setting = VideoSettings.getVideoResolution(type: type)
        rtmpStream.videoSettings[.width] = setting.width
        rtmpStream.videoSettings[.height] = setting.height
    }
}


//MARK: - GCStreamSettingsControllerDelegate
extension GCRecordViewController: GCStreamSettingsControllerDelegate {
    func selectVideoSetting(type: VideoSettings.VideoType) {
        self.videoType = type
    }
    
    func createStream(name: String) {
        networkManager.newStream(name: name)
    }
    
    func select(stream: GCStream?) {
        self.stream = stream
        rtmpStream.close()
        
        if let stream = stream {
            rtmpConnection.connect(stream.connectString)
        }
    }
    
    func closeSettings() {
        settingsVC = nil
    }
    
    func deleteStream() {
        guard let stream = stream
        else { return }
        networkManager.deleteStream(streamID: stream.id)
    }
}

//MARK: - NetworkManagerDelegate
extension GCRecordViewController: NetworkManagerDelegate {
    func didDeleteStream(id: Int) {
        select(stream: nil)
        model.streams.removeAll(where: { $0.id == id })
        
        for i in model.broadcasts.indices {
            model.broadcasts[i].streamIDs.removeAll(where: { $0 == id })
        }
        
        settingsVC?.updateStreamName(streamName)
        settingsVC?.updateData()
    }
    
    func streamDidCreate(stream: GCStream) {
        model.streams += [stream]
        settingsVC?.updateData()
    }
    
    func failedRequest(error: HTTPError) {
        switch error {
        case .response: pushErrorAllert(with: error)
        default: pushErrorAllert(with: .unexpected)
            
        }
    }
}

//MARK: - RTMPStreamDelegate
extension GCRecordViewController: RTMPStreamDelegate {
    func rtmpStreamDidClear(_ stream: RTMPStream) {
        
    }
    
    //fps and bitrate tracking
    func rtmpStream(_ stream: RTMPStream, didStatics connection: RTMPConnection) {
        DispatchQueue.main.async {
            self.fpsLabel.text = String(stream.currentFPS) + " fps"
            self.bitrateLabel.text = String((connection.currentBytesOutPerSecond / 125)) + " kbps"
        }
    }
    
    /*
     A primitive adaptive bitrate is implemented here,
     to do this, 2 methods are used:
     
     1) rtmpStream(_ stream: RTMPStream, didPublishSufficientBW connection: RTMPConnection)
     - used when bandwidth is sufficient to increase
     
     2) func rtmpStream(_ stream: RTMPStream, didPublishInsufficientBW connection: RTMPConnection)
     - used when bandwidth is insufficient to reduce
     */
    func rtmpStream(_ stream: RTMPStream, didPublishSufficientBW connection: RTMPConnection) {
        sufficientBWCount += 1
        let currentBitrate = stream.videoSettings[.bitrate] as! UInt32
        let setting = VideoSettings.getVideoResolution(type: videoType)
        
        if currentBitrate < setting.bitrate && isLive && sufficientBWCount >= 3 {
            stream.videoSettings[.bitrate] = currentBitrate + 100_000
            print("Increasing the bitrate to \(stream.videoSettings[.bitrate] ?? 0)")
        }
        
        if sufficientBWCount >= 60 {
            sufficientBWCount = 3
            insufficientBWCount = 0
        }
    }
    
    func rtmpStream(_ stream: RTMPStream, didPublishInsufficientBW connection: RTMPConnection) {
        sufficientBWCount = 0
        insufficientBWCount += 1
        let currentBitrate = stream.videoSettings[.bitrate] as! UInt32
        
        if insufficientBWCount >= 3 {
            insufficientBWCount = 0
            stream.videoSettings[.bitrate] = Double(currentBitrate) * 0.7
            print("Bitrate reduction to \(stream.videoSettings[.bitrate] ?? 0)")
        }
    }
}
