# Frame Rendering Tracing for HarmonyOS Flutter Performance Optimization

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