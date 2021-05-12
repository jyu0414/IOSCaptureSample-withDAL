//
//  NSImage.swift
//  SimpleDALPlugin
//
//  Created by Yuji Sasaki on 2021/05/13.
//  Copyright © 2021 com.seanchas116. All rights reserved.
//

import CoreImage

extension CMSampleBuffer {
    
    func CIImage() -> CIImage {
        let pixelBuffer = CMSampleBufferGetImageBuffer(self)!
        return CoreImage.CIImage(cvPixelBuffer: pixelBuffer)
    }
}


