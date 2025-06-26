##  Flutter Performance Tuning on HarmonyOS: Performance Analysis and Boundary Definition

Flutter applications adapted for HarmonyOS can be debugged using DevTools for Dart code.

**Prerequisites**

- OpenHarmony Next system
- Flutter interface running in foreground
- Analysis tools:
  DevEco Studio Profiler
  SmartPerf

**Flutter Thread Architecture**
Flutter utilizes multiple threads for essential operations. All Dart code executes on the UI thread, which impacts other threads:

- **Platform Thread**
  Main platform thread where plugin code runs
- **UI Thread**
  Executes Dart code in Dart VM. Handles:
  - Developer-written code
  - Framework-generated code
  - Creates lightweight layer trees (device-agnostic rendering commands)
  - Sends layer trees to GPU thread
    ​**Critical:**​ Never block this thread! Appears in performance overlay's bottom bar.
- **Raster Thread (GPU Thread)**
  Processes layer trees and sends to GPU. While you can't directly interact:
  - Slowness indicates Dart code issues
  - Hosts Skia graphics library
  - Appears in performance overlay's top bar
- **I/O Thread**
  Handles heavy I/O operations to prevent blocking UI/raster threads. Not shown in performance overlay.
- **RenderService Thread**
  RS process main thread. After Flutter renders frames:
  - Texture mode: Composites with main thread (affected by main thread)
  - Surface mode: Direct display (unaffected by main thread)

**Problem Boundary Definition**
In DevEco Studio:

1. Open Profiler tab
2. Capture application trace
3. Focus on `<x>.ui`, `<x>.raster`, and RenderService main threads


![image-1-301](https://p.ipic.vip/dh0ed2.png)


The missing frames in the RenderService in the above image are due to the UI thread taking a longer time per frame, exceeding one frame (at a frame rate of 120, one frame is 8.33 milliseconds).

![image-1-302](https://p.ipic.vip/pmgebf.png)


If the total duration of<x>. ui and<x>. master in a frame rendering process exceeds one frame time, the performance issue can be defined as Flutter problem. The positioning of the problem requires further performance analysis.