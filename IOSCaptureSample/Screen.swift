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
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
    
    func makeNSView(context: Context) -> some NSView {
        
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
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.externalUnknown], mediaType: .none, position: .unspecified).devices
        
        for device in devices {
            print(device.localizedName)
        }
        
        let session = AVCaptureSession()
        
        let device = devices.first(where: { $0.localizedName == "iPad" })!
        
        
        session.addInput(try! AVCaptureDeviceInput(device: device))
        
        let view = NSView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session) // avCaptureSessionは任意のAVCaptureSessionとします
        previewLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100) // previewViewは任意のUIViewとします
        previewLayer.connection?.videoOrientation = .portrait // 向きの設定
        view.wantsLayer = true
        
        
        view.layer = previewLayer
        
        session.startRunning()
        
        return view
    }
}
