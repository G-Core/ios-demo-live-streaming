//
//  VideoSetup.swift
//  GCoreLabsDemoTwo
//
//  Created by Evgeniy Polyubin on 26.11.2021.
//

import Foundation
import HaishinKit
import AVFoundation
import VideoToolbox

struct VideoSettings {
    
    enum VideoType: Int, CaseIterable {
        case v360, v480, v720

        var description: String {
            switch self {
            case .v360: return "360р"
            case .v480: return "480р"
            case .v720: return "720р"
            }
        }

        init?(description: String) {
            switch description {
            case "360р": self = .v360
            case "480р": self = .v480
            case "720р": self = .v720
            default: return nil
            }
        }
    }
    
    let bitrate: Int
    let width: Int
    let height: Int
    
    static func getVideoResolution(type: VideoType) -> VideoSettings {
        switch type {
        case .v360: return VideoSettings(bitrate: 400_000, width: 640, height: 360)
        case .v480: return VideoSettings(bitrate: 800_000, width: 854, height: 480)
        case .v720: return VideoSettings(bitrate: 2_000_000, width: 1280, height: 720)
        }
    }
    
}

struct StreamSettings {
    //Data from https://github.com/shogo4405/HaishinKit.swift
    static func presetStreamFor(_ stream: RTMPStream) {
        stream.captureSettings = [
            .fps: 30,
            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
        ]
        
        stream.audioSettings = [
            .muted: false,
            .bitrate: 128 * 1000
        ]
        
        stream.videoSettings = [
            .width: 1280,
            .height: 720,
            .bitrate: 1_500_000,
            .profileLevel: kVTProfileLevel_H264_Baseline_5_2,
            .maxKeyFrameIntervalDuration: 2
        ]
        
        stream.recorderSettings = [
            AVMediaType.audio: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 0,
                AVNumberOfChannelsKey: 0,
            ],
            AVMediaType.video: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoHeightKey: 0,
                AVVideoWidthKey: 0,
            ],
        ]
    }
}
