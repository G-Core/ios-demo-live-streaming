//
//  RTMPStreamManager.swift
//  GCoreStreamsDemo
//
//  Created by Evgeniy Polyubin on 17.03.2022.
//

import UIKit
import HaishinKit
import AVFoundation

protocol RTMPStreamManagerDelegate: AnyObject {
    func streamStaticDidChange(currentFPS: UInt16, currentBytesOutPerSecond: Int32)
}

final class RTMPStreamManager {
    let rtmpConnection = RTMPConnection()
    
    private var appState: UIApplication.State {
        UIApplication.shared.applicationState
    }
    
    lazy var rtmpStream = RTMPStream(connection: rtmpConnection)
    var stream: Stream?

    weak var delegate: RTMPStreamManagerDelegate?
    private var isLive = false
    private var sufficientBWCount = 0
    private var insufficientBWCount = 0
    private var attachedCamera = DeviceUtil.device(withPosition: .front)

    var urlType: Stream.URLPushType = .common

    var videoType: VideoSettings.VideoType = .v720 {
        didSet {
            if videoType != oldValue {
                currentVideoType = videoType
                setupVideoSetting(type: videoType)
                print(videoType)
            }
        }
    }
    
    var currentVideoType: VideoSettings.VideoType = .v480
    
    init() {
        rtmpStream.delegate = self
        rtmpStream.attachAudio(AVCaptureDevice.default(for: AVMediaType.audio))
        rtmpStream.attachCamera(attachedCamera)
        StreamSettings.presetStreamFor(rtmpStream)
        setupVideoSetting(type: videoType)
        rtmpStream.mixer.pauseImage = UIImage.blackImage?.cgImage
        subscribeNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func play() {
        print("play")
        rtmpStream.paused = false
        isLive = true
    }
    
    func pause() {
        print("pause")
        rtmpStream.paused = true
        isLive = false
    }

    func start() {
        print("start")

        guard let stream = stream else { return }
        switch urlType {
        case .common: rtmpConnection.connect(stream.rtmpConnectString ?? "")
        case .backup: rtmpConnection.connect(stream.rtmpBackupConnectString ?? "")
        }

        rtmpStream.publish(stream.rtmpPublishString)
    }

    func close() {
        print("close")
        rtmpStream.close()
    }
    
    func flipCamera(handler: @escaping (NSError?) -> Void) {
        print("flipCamera")
        let frontCamera = DeviceUtil.device(withPosition: .front)
        let backCamera = DeviceUtil.device(withPosition: .back)
        attachedCamera = attachedCamera == frontCamera ? backCamera : frontCamera
        rtmpStream.attachCamera(attachedCamera) { error in
            handler(error)
        }
    }

    func toggleMic(isOn: Bool) {
        print("toggleMic - \(isOn)")
        rtmpStream.audioSettings = [ .muted: !isOn ]
    }
    
    //Updating video settings of the stream
    private func setupVideoSetting(type: VideoSettings.VideoType) {
        let setting = VideoSettings.getVideoResolution(type: type)
        rtmpStream.videoSettings[.width] = setting.width
        rtmpStream.videoSettings[.height] = setting.height
        rtmpStream.videoSettings[.bitrate] = Double(setting.bitrate) * 0.75
    }
}

//MARK: - RTMPStreamDelegate

extension RTMPStreamManager: RTMPStreamDelegate {
    func rtmpStreamDidClear(_ stream: RTMPStream) {
        
    }
    
    func rtmpStream(_ stream: RTMPStream, didStatics connection: RTMPConnection) {
        delegate?.streamStaticDidChange(
            currentFPS: stream.currentFPS,
            currentBytesOutPerSecond: connection.currentBytesOutPerSecond
        )
    }
    
    /*
     A primitive adaptive bitrate and adaptive video resolution is implemented here,
     to do this, 2 methods are used:
     
     1) rtmpStream(_ stream: RTMPStream, didPublishSufficientBW connection: RTMPConnection)
     - used when bandwidth is sufficient to increase
     
     2) func rtmpStream(_ stream: RTMPStream, didPublishInsufficientBW connection: RTMPConnection)
     - used when bandwidth is insufficient to reduce
     */
    func rtmpStream(_ stream: RTMPStream, didPublishSufficientBW connection: RTMPConnection) {
        guard isLive, appState != .background
        else { return }
        
        sufficientBWCount += 1
        let currentBitrate = stream.videoSettings[.bitrate] as! UInt32
        let setting = VideoSettings.getVideoResolution(type: videoType)
        
        if currentBitrate < setting.bitrate && isLive && sufficientBWCount >= 3 {
            sufficientBWCount = 0
            let updatedBitrate = currentBitrate + 100_000
            stream.videoSettings[.bitrate] = updatedBitrate
            increasingResolution(bitrate: Int(updatedBitrate))
            print("Increasing the bitrate to \(stream.videoSettings[.bitrate] ?? 0)")
        }
        
        if sufficientBWCount >= 60 {
            sufficientBWCount = 0
        }
    }
    
    func rtmpStream(_ stream: RTMPStream, didPublishInsufficientBW connection: RTMPConnection) {
        guard isLive, appState != .background
        else { return }
        
        sufficientBWCount = 0
        insufficientBWCount += 1
        let currentBitrate = stream.videoSettings[.bitrate] as! UInt32
        
        if insufficientBWCount >= 3 {
            insufficientBWCount = 0
            let updatedBitrate = Double(currentBitrate) * 0.7
            stream.videoSettings[.bitrate] = updatedBitrate
            reducingResolution(bitrate: Int(updatedBitrate))
            print("Bitrate reduction to \(stream.videoSettings[.bitrate] ?? 0)")
        }
    }
    
    private func reducingResolution(bitrate: Int) {
        guard let lowerType = VideoSettings.VideoType(rawValue: currentVideoType.rawValue - 1)
        else { return }
        
        let lowerSettings = VideoSettings.getVideoResolution(type: lowerType)
        let currentSettings = VideoSettings.getVideoResolution(type: currentVideoType)
        
        if bitrate < currentSettings.bitrate - ((currentSettings.bitrate - lowerSettings.bitrate) / 2) {
            setupVideoSetting(type: lowerType)
            currentVideoType = lowerType
            print("Reducing the resolutin to \(lowerSettings.width) x \(lowerSettings.height)")
        }
    }
    
    private func increasingResolution(bitrate: Int) {
        guard let upperType = VideoSettings.VideoType(rawValue: currentVideoType.rawValue + 1),
              upperType.rawValue <= videoType.rawValue
        else { return }
        
        let upperSettings = VideoSettings.getVideoResolution(type: upperType)
        let currentSettings = VideoSettings.getVideoResolution(type: currentVideoType)
        
        if bitrate > currentSettings.bitrate - ((currentSettings.bitrate - upperSettings.bitrate) / 2) {
            setupVideoSetting(type: upperType)
            currentVideoType = upperType
            print("Increasing the resolutin to \(upperSettings.width) x \(upperSettings.height)")
        }
    }
}

// MARK: -  extension for streaming in the background

extension RTMPStreamManager {
    private func subscribeNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackgroundNotification),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    @objc private func didEnterBackgroundNotification(_ notification: Notification) {
        rtmpStream.videoSettings[.height] = 240
        rtmpStream.videoSettings[.width] = 426
    }
    
    @objc private func willResignActiveNotification(_ notification: Notification) {
        rtmpStream.attachCamera(nil)
    }
    
    @objc private func didBecomeActiveNotification(_ notification: Notification) {
        rtmpStream.attachCamera(attachedCamera)
        
        let settings = VideoSettings.getVideoResolution(type: currentVideoType)
        rtmpStream.videoSettings[.height] = settings.height
        rtmpStream.videoSettings[.width] = settings.width
    }
}
