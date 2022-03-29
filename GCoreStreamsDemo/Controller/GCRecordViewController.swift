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
    private var rtmpManager = RTMPStreamManager()
    private var streamName: String { gcStream?.name ?? "Stream not chosen" }
    private var settingsVC: GCStreamSettingsController?
    
    private var gcStream: GCStream? {
        get { rtmpManager.gcStream }
        set { rtmpManager.gcStream = newValue }
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
        view.addSubview(playButton)
        view.addSubview(configureButton)
        view.addSubview(flipButton)
        view.addSubview(fpsLabel)
        view.addSubview(bitrateLabel)
        networkManager.token = model.accessToken
        rtmpManager.delegate = self
        createConstraints()
    }
    
    @objc private func tapPlayButton() {
        guard gcStream != nil
        else { return }
        
        if playButton.image(for: .normal) == .playImage {
            rtmpManager.play()
            playButton.setImage(.pauseImage, for: .normal)
            configureButton.isUserInteractionEnabled = false
            configureButton.alpha = 0.5
            tabBarController?.tabBar.isHidden = true
        } else {
            rtmpManager.pause()
            playButton.setImage(.playImage, for: .normal)
            configureButton.isUserInteractionEnabled = true
            configureButton.alpha = 1
            tabBarController?.tabBar.isHidden = false
        }
    }
    
    @objc private func tapFlipButton() {
        rtmpManager.flipCamera()
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
    
    private func setupHaishinKit() {
        hkView.frame = view.bounds
        hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        hkView.backgroundColor = .black
        hkView.attachStream(rtmpManager.rtmpStream)
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
}


//MARK: - GCStreamSettingsControllerDelegate
extension GCRecordViewController: GCStreamSettingsControllerDelegate {
    var videoType: VideoSettings.VideoType {
        get { rtmpManager.videoType }
        set { rtmpManager.videoType = newValue }
    }
    
    func selectVideoSetting(type: VideoSettings.VideoType) {
        videoType = type
    }
    
    func createStream(name: String) {
        networkManager.newStream(name: name)
    }
    
    func select(stream: GCStream?) {
        self.gcStream = stream
        rtmpManager.rtmpStream.close()
        
        if let stream = stream {
            rtmpManager.rtmpConnection.connect(stream.connectString)
        }
    }
    
    func closeSettings() {
        settingsVC = nil
    }
    
    func deleteStream() {
        guard let gcStream = gcStream
        else { return }
        networkManager.deleteStream(streamID: gcStream.id)
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
extension GCRecordViewController: RTMPStreamManagerDelegate {
    
    //fps and bitrate tracking
    func streamStaticDidChange(currentFPS: UInt16, currentBytesOutPerSecond: Int32) {
        DispatchQueue.main.async {
            self.fpsLabel.text = String(currentFPS) + " fps"
            self.bitrateLabel.text = String((currentBytesOutPerSecond / 125)) + " kbps"
        }
    }
}

//MARK: - Layout
extension GCRecordViewController {
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
}
