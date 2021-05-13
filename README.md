# IOSCaptureSample with DAL
This project includes the following systems.

- iOSMirror; The virtual WebCam plugin which streams an iOS screen on macOS.
- IOSCaptureSample; The WebCam viewer can choose iOS devices as a stream source.

## iOSMirror

iOSMirror is a DAL plugin (Virtual WebCam) for showing iOS screen on chrome web app or other macOS applications. You may not use some macOS applications, because recently a part of macOS applications, including Zoom, deny third-party virtual webcam plugins.

<img src="https://user-images.githubusercontent.com/7841984/118077541-3dc7ec00-b3ef-11eb-919c-ad58e40574d3.gif" width=50% alt="DEMO"/>

### License

This project is based on the following repositories.

- [SimpleDALPlugin](https://github.com/seanchas116/SimpleDALPlugin)
- [VirtualCameraComposer-Example](https://github.com/kishikawakatsumi/VirtualCameraComposer-Example)

### Usage

1. Build iOSMirror project on Xcode
2. Copy generated plugin into `/Library/CoreMediaIO/Plug-Ins/DAL`
3. You can see this plugin from meeting apps such as Google Meet on Chrome.

## IOSCaptureSample

This example shows how access iOS screen as WebCamera device using AVFoundation. Quick Time can access to iOS but it is denied normally. In this program, we need to opt in iOS access explicitly.

### Usage

- Build on Xcode and you can use this app. It may not work without code signing.
- You can choose video sources using Touchpad on your MacBook Pro.
