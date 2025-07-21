# Frame Rendering Tracing for HarmonyOS Flutter Performance Optimization

HarmonyOS Next, when paired with Flutter, offers improved performance through several optimizations. Specifically, it utilizes the Impeller rendering engine, which provides a GPU hardware-level synchronization mechanism to prevent data conflicts and reduce idling time. This, combined_with render pipeline preloading, helps minimize white screen time and latency. Additionally, HarmonyOS Next itself is designed for enhanced performance and a smoother user experience compared to previous versions. 
Here's a more detailed breakdown:
Impeller Rendering Engine:
HarmonyOS Next leverages Flutter's Impeller engine, which optimizes graphics rendering by using GPU hardware synchronization. This avoids data competition and reduces idling time, leading to improved performance. 
Render Pipeline Preloading:
Impeller precompiles shaders to avoid runtime compilation. To further enhance performance, HarmonyOS Next preloads the render pipeline during startup, which reduces the initial frame loading time and minimizes latency. 
Deterministic Latency Engine:
HarmonyOS is equipped with a deterministic latency engine that prioritizes events, improving Inter-Process Communication (IPC) and overall system responsiveness. 
HarmonyOS NEXT's Native Focus:
HarmonyOS NEXT is a fully independent operating system that does not rely on the Android framework. This allows for deeper integration and optimization of the system's performance. 
Flutter Thread Architecture:
Understanding Flutter's threading model (UI, raster, and I/O threads) is crucial for performance tuning. Optimizing the Dart code on the UI thread is essential, as it impacts the other threads. Using tools like DevTools and Profiler can help identify performance bottlenecks. 
RepaintBoundary:
Wrapping frequently updated widgets with RepaintBoundary can prevent unnecessary repaints of the entire screen, improving performance, especially in complex UIs. 



## Introduction
When analyzing Flutter application performance, developers need to capture and examine trace data using specialized tools. This document introduces a targeted approach for tracing individual frame rendering, particularly useful for diagnosing frame rate drops or frame loss issues.

## Analysis Tools
Recommended performance analysis tools:
1. **[DevEco Studio Profiler](https://developer.huawei.com/consumer/cn/download/)**  
   Comprehensive performance analysis suite for HarmonyOS applications
2. **[SmartPerf](https://gitee.com/openharmony-sig/smartperf)**  
   Open-source performance monitoring solution

> **Usage Guide**:  
> Refer to [DevEco Profiler Tool Introduction](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/deep-recording-V5) for detailed instructions.

## Frame Rendering Process
The frame rendering workflow consists of three key stages:



Understanding this workflow and identifying matching markers across stages is crucial for accurate frame tracing.

### First Identifier: frame_number
The `frame_number` serves as the primary identifier linking the UI and rasterization threads:



**Key observations**:
- The `frame_number` appears in both 1.ui and 1.raster threads
- This identifier connects UI processing with rasterization
- If missing, indicates non-Flutter rendering requiring further investigation

### Second Identifier: ReuseBuffer/acquire buffer
The `ReuseBuffer` identifier connects rasterization with the render service:

#### Raster Thread (1.raster)
During `flutter::SkCanvas::Flush`:
- Requests buffer memory from RS process
- Stores rendered frame content
- Visible in "binder transaction" trace



#### Render Service Thread (render_service)
During `RSMainThread::DoComposition`:
- Retrieves frame content from buffer memory
- Matching `acquire buffer sequence` ID confirms connection



## Tracing Methodology
1. **Identify frame_number**:
   - Locate matching values in UI and raster threads
   - Confirm Flutter rendering context

2. **Track Buffer Transfer**:
   - Match `ReuseBuffer` ID in raster thread
   - Verify corresponding `acquire buffer sequence` in render service
   - Confirm frame content transfer

3. **Continuous Thread Tracing**:
   - Render service → RSUniRenderThread → RSHardwareThread
   - Assumes sequential processing within the same frame

## Practical Application
This tracing approach enables:
- Precise identification of rendering bottlenecks
- Isolation of frame-specific performance issues
- Differentiation between Flutter and native rendering problems
- Targeted optimization of critical rendering paths

> **Note**: While the first two stages have clear identifiers, subsequent stages (RSUniRenderThread to RSHardwareThread) currently rely on continuous thread tracing assumptions due to lack of explicit markers.
