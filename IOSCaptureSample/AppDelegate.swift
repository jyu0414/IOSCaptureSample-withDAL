//
//  AppDelegate.swift
//  IOSCaptureSample
//
//  Created by Yuji Sasaki on 2021/05/11.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        for i in 1...6 {
            NSApplication.shared.mainMenu?.items[i].isHidden = true
        }
        
    }
}
