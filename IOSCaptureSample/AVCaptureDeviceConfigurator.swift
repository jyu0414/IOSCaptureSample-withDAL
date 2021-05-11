//
//  AVCaptureDeviceConfigurator.swift
//  IOSCaptureSample
//
//  Created by Yuji Sasaki on 2021/05/11.
//

import AVFoundation
import CoreMediaIO

class AVCaptureDeviceConfigurator {
    
    static var shared = AVCaptureDeviceConfigurator()
    
    var devices: [AVCaptureDevice] = []
    
    private init() {
        update()
    }
    
    func update() {
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
        self.devices = discoverySession.devices
        
    }
}

