//
//  Stream.swift
//  SimpleDALPlugin
//
//  Created by 池上涼平 on 2020/04/25.
//  Copyright © 2020 com.seanchas116. All rights reserved.
//

import CoreImage

class Stream: Object, IOSScreenCaptureDelegate {
    var objectID: CMIOObjectID = 0
    let name = "iOSMirror"
    var width = 1280
    var height = 720
    let frameRate = 30

    private var sequenceNumber: UInt64 = 0
    private var queueAlteredProc: CMIODeviceStreamQueueAlteredProc?
    private var queueAlteredRefCon: UnsafeMutableRawPointer?
    
    private var iOSScreenCapture: IOSScreenCapture?
    private var currentScreen: CIImage?
    private var lastPixelBuffer: CVPixelBuffer?

    private lazy var formatDescription: CMVideoFormatDescription? = {
        var formatDescription: CMVideoFormatDescription?
        let error = CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCVPixelFormatType_32ARGB,
            width: Int32(width), height: Int32(height),
            extensions: nil,
            formatDescriptionOut: &formatDescription)
        guard error == noErr else {
            return nil
        }
        return formatDescription
    }()

    private lazy var clock: CFTypeRef? = {
        var clock: Unmanaged<CFTypeRef>? = nil

        let error = CMIOStreamClockCreate(
            kCFAllocatorDefault,
            "iOSMirror clock" as CFString,
            Unmanaged.passUnretained(self).toOpaque(),
            CMTimeMake(value: 1, timescale: 10),
            100, 10,
            &clock);
        guard error == noErr else {
            log("CMIOStreamClockCreate Error: \(error)")
            return nil
        }
        return clock?.takeUnretainedValue()
    }()

    private lazy var queue: CMSimpleQueue? = {
        var queue: CMSimpleQueue?
        let error = CMSimpleQueueCreate(
            allocator: kCFAllocatorDefault,
            capacity: 30,
            queueOut: &queue)
        guard error == noErr else {
            log("CMSimpleQueueCreate Error: \(error)")
            return nil
        }
        return queue
    }()

    private lazy var timer: DispatchSourceTimer = {
        let interval = 1.0 / Double(frameRate)
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + interval, repeating: .milliseconds(1000 / frameRate))
        timer.setEventHandler(handler: { [weak self] in
            self?.enqueueBuffer()
        })
        return timer
    }()

    lazy var properties: [Int : Property] = [
        kCMIOObjectPropertyName: Property(name),
        kCMIOStreamPropertyFormatDescription: Property(formatDescription!),
        kCMIOStreamPropertyFormatDescriptions: Property([formatDescription!] as CFArray),
        kCMIOStreamPropertyDirection: Property(UInt32(0)),
        kCMIOStreamPropertyFrameRate: Property(Float64(frameRate)),
        kCMIOStreamPropertyFrameRates: Property(Float64(frameRate)),
        kCMIOStreamPropertyMinimumFrameRate: Property(Float64(frameRate)),
        kCMIOStreamPropertyFrameRateRanges: Property(AudioValueRange(mMinimum: Float64(frameRate), mMaximum: Float64(frameRate))),
        kCMIOStreamPropertyClock: Property(CFTypeRefWrapper(ref: clock!)),
    ]

    func start() {
        iOSScreenCapture = IOSScreenCapture()
        iOSScreenCapture!.delegate = self
        iOSScreenCapture!.start()
        enqueueBuffer()
        timer.resume()
    }

    func stop() {
        iOSScreenCapture?.stop()
        timer.suspend()
    }

    func copyBufferQueue(queueAlteredProc: CMIODeviceStreamQueueAlteredProc?, queueAlteredRefCon: UnsafeMutableRawPointer?) -> CMSimpleQueue? {
        self.queueAlteredProc = queueAlteredProc
        self.queueAlteredRefCon = queueAlteredRefCon
        return self.queue
    }
    
    private func createBackgroundBuffer() -> CVPixelBuffer {
        let newBuffer = CVPixelBuffer.create(size: CGSize(width: width, height: height))!
        newBuffer.modifyWithContext { [width, height] context in
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        return newBuffer
    }

    private func createPixelBuffer() -> CVPixelBuffer? {
        
//        if width != lastPixelBuffer?.width || height != lastPixelBuffer?.height {
//            lastPixelBuffer = createBackgroundBuffer()
//        }
        
        let pixelBuffer = lastPixelBuffer ?? createBackgroundBuffer()
        
        let context = CIContext()
        
        guard let currentScreen = currentScreen else { return pixelBuffer }
        
        let newHeight = CGFloat(height)
        let newWidth = currentScreen.extent.width / currentScreen.extent.height * newHeight
        let newImage = currentScreen
            .transformed(by:CGAffineTransform(scaleX: newWidth / currentScreen.extent.width, y: newHeight / currentScreen.extent.height))
            .transformed(by: CGAffineTransform(translationX: (CGFloat(width) - newWidth) / 2, y: 0))
                        .cropped(to: CGRect(origin: .zero, size: CGSize(width: width, height: height)))

        context.render(newImage, to: pixelBuffer)

        return pixelBuffer
    }
    
    func enqueueBuffer(sampleBuffer: CMSampleBuffer) {
        currentScreen = sampleBuffer.CIImage()
//        width = Int(currentScreen?.extent.width ?? 1280)
//        height = Int(currentScreen?.extent.height ?? 720)
    }

    private func enqueueBuffer() {
        
        guard let queue = queue else {
            log("queue is nil")
            return
        }

        guard CMSimpleQueueGetCount(queue) < CMSimpleQueueGetCapacity(queue) else {
            log("queue is full")
            return
        }

        guard let pixelBuffer = createPixelBuffer() else {
            log("pixelBuffer is nil")
            return
        }

        let scale = UInt64(frameRate) * 100
        let duration = CMTime(value: CMTimeValue(scale / UInt64(frameRate)), timescale: CMTimeScale(scale))
        let timestamp = CMTime(value: duration.value * CMTimeValue(sequenceNumber), timescale: CMTimeScale(scale))

        var timing = CMSampleTimingInfo(
            duration: duration,
            presentationTimeStamp: timestamp,
            decodeTimeStamp: timestamp
        )

        var error = noErr

        error = CMIOStreamClockPostTimingEvent(timestamp, mach_absolute_time(), true, clock)
        guard error == noErr else {
            log("CMSimpleQueueCreate Error: \(error)")
            return
        }

        var formatDescription: CMFormatDescription?
        error = CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription)
        guard error == noErr else {
            log("CMVideoFormatDescriptionCreateForImageBuffer Error: \(error)")
            return
        }

        var sampleBufferUnmanaged: Unmanaged<CMSampleBuffer>? = nil
        error = CMIOSampleBufferCreateForImageBuffer(
            kCFAllocatorDefault,
            pixelBuffer,
            formatDescription,
            &timing,
            sequenceNumber,
            UInt32(kCMIOSampleBufferNoDiscontinuities),
            &sampleBufferUnmanaged
        )
        guard error == noErr else {
            log("CMIOSampleBufferCreateForImageBuffer Error: \(error)")
            return
        }
        

        CMSimpleQueueEnqueue(queue, element: sampleBufferUnmanaged!.toOpaque())
        queueAlteredProc?(objectID, sampleBufferUnmanaged!.toOpaque(), queueAlteredRefCon)
        
        sequenceNumber += 1
    }
}
