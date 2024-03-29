# Gcore – Stream Live Video Online on iOS

## Demo
<img src="/gif/iOS_Live_demo_github.gif" height="800"/>

## Introduction
Set up live streaming in 15 minutes in your iOS project instead of 7 days of work and setting wild parameters of codecs, network, etc. This demo project is a quick tutorial how to stream live video from your own mobile app to an audience of 1 000 000+ viewers like Instagram, Youtube, etc.

## Feature
1) HLS & MPEG-DASH playback

2) RTMP streaming

3) Flip camera, authorization, new stream/broadcast creation

4) Video: <br />
  Network adaptive bitrate mechanism <br />
  Network adaptive resolution mechanism <br />
  Source: front and back cameras <br />
  Orientation: portrait <br />
  Codec: H.264 <br />
  Configurable bitrate, resolution, framerate, encoder level, encoder profile <br />
  
5) Audio: <br />
  Codec: AAC  <br />
  Configurable bitrate, sample rate <br />
  Sending in the background <br />
 
## Quick start 
  1) Launching the application via xcode (it must be run on a real device, since the simulator does not support the camera),
  2) Authorization via email and password of the personal account in G-Core Labs,
  3) On the broadcast screen, you can start viewing available broadcasts,
  4) On the streams screen, you can start broadcasting, adjust the video quality, create/delete streams/broadcasts.

## Setup of project
Clone this project and try it or create a new one.

1) Library <br />
  To work with rtmp, you will need a third-party library, [HaishinKit](https://github.com/shogo4405/HaishinKit.swift) is used in this project. You can install it on your project via SPM (swift package manager). <br />
  This project contains its own version of the library, with added functionality for streaming in the background (sending audio, without video)
  
2) Permissions <br />
  To use the camera and microphone, you need to request the user's permission for this. To do this, add to the plist (Info) of the project:
  **Privacy - Camera Usage Description** and **Privacy - Microphone Usage Description**. <br />

    Also, to record sound in the background, you need to add a **background mode** - **"Audio, AirPlay and Picture in Picture"**
  
3) Audio session <br />
  Setting up an audio session for the application takes place in AppDelegate in the method:
  
  ```swift
   private func setupSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            mode: .default,
                                                            options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error.localizedDescription)
        }
    }
  ```
  
4) Stream settings <br />
    The initial setup of the stream occurs in the method of the **StreamSettings** structure.
    ```swift
    static func presetStreamFor(_ stream: RTMPStream) {
        stream.captureSettings = [
            .fps: 30,
            .sessionPreset: AVCaptureSession.Preset.hd1280x720,
        ]
        
        stream.audioSettings = [
            .muted: false,
            .bitrate: 128 * 1000,
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
    ```
5) GCore API
  To interact with the server, the **HTTPCommunicator** structure is used, through the API:
  ```swift
enum GcoreAPI: String {
    case authorization = "https://api.gcorelabs.com/iam/auth/jwt/login"
    case refreshToken = "https://api.gcorelabs.com/iam/auth/jwt/refresh"
    case streams = "https://api.gcorelabs.com/streaming/streams"
    case broadcasts = "https://api.gcorelabs.com/streaming/broadcasts"
}
  ```
  Which create the necessary request through the **HTTPCommunication** class.
  For more check G-Core Labs API [documentation](https://apidocs.gcorelabs.com/streaming#tag/Streams).
  
## Requirements
  1) iOS min - 12.1,
  2) Real device (not simulator),
  3) The presence of an Internet connection on the device,
  4) The presence of a camera and microphone on the device.
  
## License
Copyright 2022 Gcore
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

