//
//  Screen.swift
//  IOSCaptureSample
//
//  Created by Yuji Sasaki on 2021/05/11.
//

import AppKit
import SwiftUI

import CoreMediaIO
import AVFoundation

struct Screen: NSViewRepresentable, ScreenDelegate {
    
    @Binding var device: AVCaptureDevice?
    @Binding var aspectRatio: CGFloat
    private var captureHandler = CaptureHandler()
    
    init(device: Binding<AVCaptureDevice?>, aspectRatio: Binding<CGFloat>) {
        self._device = device
        self._aspectRatio = aspectRatio
        captureHandler.delegate = self
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let device = device else { return }
        nsView.layer = captureHandler.getInput(for: device)
    }
    
    func update(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
    }
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSView()
        view.wantsLayer = true
        if let device = device {
            view.layer = captureHandler.getInput(for: device)
        }
        return view
    }
    
}

class CaptureHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var delegate: ScreenDelegate?
    
    func getInput(for device: AVCaptureDevice) -> CALayer? {
        let session = AVCaptureSession()
        
        //output
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .main)
        session.addOutput(output)
        
        //input
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("error make capture device input")
            print(error.localizedDescription)
            return nil
        }
        session.addInput(input!)
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.connection?.videoOrientation = .portrait
        
        session.startRunning()
        
        return previewLayer
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let w = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let h = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        delegate?.update(aspectRatio: w / h)
    }
}

protocol ScreenDelegate {
    func update(aspectRatio: CGFloat)
}
