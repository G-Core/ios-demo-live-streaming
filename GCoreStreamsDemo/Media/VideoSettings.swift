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
    
    enum VideoType: Int {
        case lq, sq, hq, shq, hd720
    }
    
    let bitrate: Int
    let width: Int
    let height: Int
    
    static func getVideoResolution(type: VideoType) -> VideoSettings {
        switch type {
        case .lq: return VideoSettings(bitrate: 280 * 1000, width: 480, height: 270)
        case .sq: return VideoSettings(bitrate: 480 * 1000, width: 720, height: 405)
        case .hq: return VideoSettings(bitrate: 950 * 1000, width: 720, height: 405)
        case .shq: return VideoSettings(bitrate: 1500 * 1000, width: 720, height: 576)
        case .hd720: return VideoSettings(bitrate: 2300 * 1000, width: 1280, height: 720)
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
            .bitrate: 1_000_000,
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
