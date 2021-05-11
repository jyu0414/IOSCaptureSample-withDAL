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

struct Screen: NSViewRepresentable {
    
    @Binding var device: AVCaptureDevice?
    @Binding var aspectRatio: CGFloat
    var currentInput: AVCaptureDeviceInput?
    
    init(device: Binding<AVCaptureDevice?>, aspectRatio: Binding<CGFloat>) {
        self._device = device
        self._aspectRatio = aspectRatio
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        nsView.layer = setInput()
    }
    
    func setInput() -> CALayer? {
        print("start setinput")
        guard let device = device  else {
            return nil
        }
        
        var newInput: AVCaptureDeviceInput?
        let session = AVCaptureSession()
        
        do {
            newInput = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            print("error make capture device input")
            print(error.localizedDescription)
            return nil
        }
        
        print("newinput")
        session.addInput(newInput!)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.connection?.videoOrientation = .portrait
        
        print("before start")
        session.startRunning()
        print("started")
        
        return previewLayer
    }
    
    func makeNSView(context: Context) -> some NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer = setInput()
        return view
    }
    
}
