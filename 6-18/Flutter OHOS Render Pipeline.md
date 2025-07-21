# First Step in Performance Analysis: Understanding Thread Sequencing

When analyzing the performance of Flutter applications, developers need to capture application traces using profiling tools and analyze these traces. Flutter's rendering process relies on several critical threads. This guide introduces these essential threads and their sequence in the rendering workflow.

HarmonyOS Next introduces a new thread sequencing model designed for improved performance and resource management, especially within its microkernel architecture. This model distinguishes between different thread types for specific tasks, optimizing resource allocation and preventing performance bottlenecks. 
Here's a breakdown of the key aspects:
Thread Types:
Main Thread:
Handles user interface (UI) services and non-time-consuming operations, including single I/O tasks.
High-Concurrency Task Pool:
Executes time-consuming tasks, encapsulates task execution logic, and manages module loading. It does not require explicit thread lifecycle management.
Worker Thread:
Used for long-running, CPU-intensive tasks and resident tasks. There's a limit on the number of worker threads (currently 64).
FFRT Task Pool:
A dedicated task pool for specific functionalities. 
Benefits of the New Model:
Reduced Blocking:
By offloading tasks to different thread types, the main thread is less likely to be blocked by time-consuming operations, leading to smoother UI performance and responsiveness.
Improved Resource Utilization:
The task pool approach allows for more efficient management of resources, particularly in scenarios with high concurrency.
Enhanced Stability:
By separating tasks and managing them within dedicated thread pools, the system can better handle complex operations and prevent crashes or freezes.
Simplified Development:
The use of task pools and worker threads can simplify the process of handling concurrent operations, making it easier for developers to write efficient and robust code. 
Practical Implications:
Instant Messaging SDK Example:
In the context of an Instant Messaging (IM) SDK, the new thread model helps address issues like delayed message reception and UI freezing by offloading I/O operations and other computationally expensive tasks to appropriate thread types.
Avoiding Refactoring:
While multi-threading mechanisms like Worker and TaskPool were considered, the refactoring cost of switching from a single-threaded approach to a non-shared memory multi-threading model was high, leading to the adoption of the new thread sequencing model. 
In essence, HarmonyOS Next's thread sequencing is designed to deliver a more responsive, stable, and efficient user experience by optimizing how the system handles different types of tasks across various thread types. 
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

