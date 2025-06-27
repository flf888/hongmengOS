# First Step in Performance Analysis: Understanding Thread Sequencing

When analyzing the performance of Flutter applications, developers need to capture application traces using profiling tools and analyze these traces. Flutter's rendering process relies on several critical threads. This guide introduces these essential threads and their sequence in the rendering workflow.

## Analysis Tools  
Commonly used tools include:  
- [DevEco Studio Profiler](https://developer.huawei.com/consumer/cn/download/)  
- [SmartPerf](https://gitee.com/openharmony-sig/smartperf)  

**Recommended Tool**: DevEco Studio Profiler  
For usage instructions, see:  
[DevEco Profiler Tool Introduction](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/deep-recording-V5)

## Thread Sequence  
After mastering the profiling tools, you can capture traces of Flutter applications. Traces contain all threads during application runtime. For effective analysis, bookmark and arrange threads in the following order:

### Bookmarked Threads Explained  
1. **VSyncGenerator**  
   Software Vsync signal generator that provides frame synchronization capabilities.

2. **DVSync-app**  
   Delivers software Vsync signals to the application.

3. **mmi_service**  
   Handles multimodal input events triggered by touchscreen interactions.

4. **Main Application Thread**  
   The primary thread matching the application process ID and name.  
   Hosts platform-level operations and plugin code execution.

5. **flutter'PointerEvent'**  
   Thread transferring touch events from the main thread to the UI thread for processing.  
   *(May not always appear in traces)*.

6. **1.ui (UI Thread)**  
   Executes Dart code in the Dart VM.  
   - Processes developer code and framework-generated logic  
   - Builds the layer tree (device-independent rendering commands)  
   - Transfers layer tree to the raster thread  
   **Critical**: Never block this thread! Appears at the bottom of performance layers.

7. **1.raster (Raster Thread)**  
   Processes the layer tree and communicates with the GPU.  
   - Executes Skia graphics library operations  
   - Performs rasterization for the GPU (runs on CPU)  
   - Appears at the top of performance layers.  
   *Note: Slowdowns indicate issues in Dart code logic.*

8. **DVSync-rs**  
   Provides software Vsync signals to the Render Service (RS) process.

9. **render_service**  
   Main thread of the RS process (first stage of display processing).

10. **RSUniRenderThread**  
    RS process thread (second stage of display processing).

11. **RSHardwareThread**  
    RS process thread (third stage of display processing).

12. **dpu_gfx_primary**  
    Hardware DPU (Display Processing Unit) signal thread.

