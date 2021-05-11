//
//  ContentView.swift
//  IOSCaptureSample
//
//  Created by Yuji Sasaki on 2021/05/11.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var devices: [AVCaptureDevice] = []
    @State var device: AVCaptureDevice?
    @Binding var aspectRatio: CGFloat
    
    func update() {
        AVCaptureDeviceConfigurator.shared.update()
        devices = AVCaptureDeviceConfigurator.shared.devices
        device = devices.first
    }
    
    var body: some View {
        Screen(device: $device, aspectRatio: $aspectRatio).focusable().touchBar(TouchBar {
            if devices.isEmpty {
                Text("There is no devices!")
            } else {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(devices, id: \.self) { device in
                            Button("\(device.localizedName)") {
                                self.device = device
                            }
                        }
                    }
                }
                
            }
        })
        .onAppear {
            update()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AVCaptureDeviceWasDisconnected)) { _ in
            update()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.AVCaptureDeviceWasDisconnected)) { _ in
            update()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(aspectRatio: .constant(1.5))
    }
}
