//
//  GCoreExtension.swift
//  
//
//  Created by GCore on 14.03.2022.
//

import Foundation
import AVFoundation

extension AVMixer {
    var hasOnlyMicrophone: Bool {
        session.inputs.count == 1 && session.inputs.contains(where: {$0 == audioIO.input})
    }
    
    func pushPauseImageIntoVideoStream(captureOutputData: (captureOutput: AVCaptureOutput,
                                                           captureConnection: AVCaptureConnection),
                                       timingInfo: inout CMSampleTimingInfo) {
        
        guard let pauseImage = pauseImage,
              let pixelBuffer = pixelBufferFromCGImage(image: pauseImage),
              let sampleBuffer = createBuffer(pixelBuffer: pixelBuffer, timingInfo: &timingInfo)
        else { return }
        
        videoIO.captureOutput(captureOutputData.captureOutput, didOutput: sampleBuffer, from: captureOutputData.captureConnection)
    }
    
    private func pixelBufferFromCGImage(image: CGImage) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        let width:Int = 1280
        let height:Int = 720
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32ARGB,
                            attrs,
                            &pixelBuffer)
        
        return pixelBuffer
    }
    
    private func createBuffer(pixelBuffer: CVImageBuffer, timingInfo: inout CMSampleTimingInfo) -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        
        var formatDescription: CMFormatDescription? = nil
        
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: pixelBuffer,
                                                     formatDescriptionOut: &formatDescription)
        
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDescription!,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBuffer
        )
        
        return sampleBuffer
    }
}

