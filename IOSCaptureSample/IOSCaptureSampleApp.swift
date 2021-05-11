//
//  IOSCaptureSampleApp.swift
//  IOSCaptureSample
//
//  Created by Yuji Sasaki on 2021/05/11.
//

import SwiftUI

@main
struct IOSCaptureSampleApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var aspectRatio: CGFloat = 1.5
    
    var body: some Scene {
        WindowGroup {
            ContentView(aspectRatio: $aspectRatio)
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        
        
    }
}
