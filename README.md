# IOSCaptureSample with DAL
This project includes the following systems.

- iOSMirror; The virtual WebCam plugin which streams an iOS screen on macOS.
- IOSCaptureSample; The WebCam viewer can choose iOS devices as a stream source.

## iOSMirror

iOSMirror is a DAL plugin (Virtual WebCam) for showing iOS screen on chrome web app or other macOS applications. You may not use some macOS applications, because recently a part of macOS applications, including Zoom, deny third-party virtual webcam plugins.

![Image from Gyazo](https://gyazo.com/b8fcfb99056803ae1f4a561e5d207767)

### License

This project is based on the following repositories.

- [SimpleDALPlugin](https://github.com/seanchas116/SimpleDALPlugin)
- [VirtualCameraComposer-Example](https://github.com/kishikawakatsumi/VirtualCameraComposer-Example)

### Usage

1. Build iOSMirror project on Xcode
2. Copy generated plugin into `/Library/CoreMediaIO/Plug-Ins/DAL`
3. You can see this plugin from meeting apps such as Google Meet on Chrome.
