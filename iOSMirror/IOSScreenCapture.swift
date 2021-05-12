//
//  IOSScreenCapture.swift
//  SimpleDALPlugin
//
//  Created by Yuji Sasaki on 2021/05/12.
//  Copyright © 2021 com.seanchas116. All rights reserved.
//

import AVFoundation
import CoreMediaIO

class IOSScreenCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var device: AVCaptureDevice?
    private var captureSession: AVCaptureSession?
    var delegate: IOSScreenCaptureDelegate?
    
    override init() {
        super.init()
        func updateDeviceList(notification: Notification) {
            self.discoverDevices()
            self.setCaptureSession()
        }
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasDisconnected, object: nil, queue: .main, using: updateDeviceList)
        NotificationCenter.default.addObserver(forName: .AVCaptureDeviceWasConnected, object: nil, queue: .main, using: updateDeviceList)
        discoverDevices()
        setCaptureSession()
    }
    
    private func discoverDevices() {
        var prop = CMIOObjectPropertyAddress(
            mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
            mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
            mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
        
        var allow: UInt32 = 1;
        
        CMIOObjectSetPropertyData(
            CMIOObjectID(kCMIOObjectSystemObject),
            &prop,
            0,
            nil,
            UInt32(MemoryLayout.size(ofValue: allow)),
            &allow)
        
        sleep(1)
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown, .builtInWideAngleCamera], mediaType: .none, position: .unspecified)
        
        if let device = discoverySession.devices.filter({ $0.modelID == "iOS Device" && $0.manufacturer == "Apple Inc." }).first {
            self.device = device
        }
        
    }
    
    private func setCaptureSession() {
        
        guard let device = device else { return }
        captureSession?.stopRunning()
        
        let session = AVCaptureSession()
        let output = AVCaptureVideoDataOutput()
        
        output.setSampleBufferDelegate(self, queue: .main)
        
        do {
            session.addInput(try AVCaptureDeviceInput(device: device))
        } catch let error {
            log(error)
        }
        
        session.addOutput(output)
        session.startRunning()
        captureSession = session
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.enqueueBuffer(sampleBuffer: sampleBuffer)
    }
    
    func start() {
        captureSession?.startRunning()
    }
    
    func stop() {
        captureSession?.stopRunning()
    }
}

protocol IOSScreenCaptureDelegate {
    func enqueueBuffer(sampleBuffer: CMSampleBuffer)
}
