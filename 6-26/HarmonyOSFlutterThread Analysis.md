## HarmonyOS Flutter: Thread Analysis

### **Thread Execution Order**

To analyze Flutter performance using trace tools:

1. **Collect threads**: Capture all threads during app runtime.

2. 

   Sort by sequence

   : Arrange threads in the order shown below (numbers indicate priority).

   - 1️⃣ **VSyncGennerator**
   - 2️⃣ **DVSync-app**
   - 3️⃣ **mmi_service**
   - 4️⃣ **Application Main Thread**
   - 5️⃣ **flutter.PointerEvent**
   - 6️⃣ **1.ui**
   - 7️⃣ **1.raster**
   - 8️⃣ **DVSync-rs**
   - 9️⃣ **RenderService**
   - 🔟 **RSUniRenderThread**
   - ⚙️ **RSHardwareThread**
   - 🔄 **dpu_gfx_primary**

https://p.ipic.vip/2ueyv5.png
 *After collection, threads appear in reverse order (top → bottom):*
 https://p.ipic.vip/pumt1l.png
 https://p.ipic.vip/5v10cw.png
 https://p.ipic.vip/0rz887.png

------

### **Thread Descriptions**

1. **VSyncGennerator**
   - Generates software VSync signals to track frame timing.
2. **DVSync-app**
   - Delivers software VSync signals to the Flutter app.
3. **mmi_service**
   - Handles multi-modal input events (e.g., touch gestures).
4. **Application Main Thread**
   - Main thread of the OS process (name/process ID match).
   - Runs plugin code and platform-dependent logic.
5. **flutter.PointerEvent**
   - Transfers touch events from the Flutter engine to the UI thread (may not always exist).
6. **1.ui (UI Thread)**
   - Executes Dart code in the Dart VM.
   - Builds the **Layer Tree** (device-independent rendering commands).
   - Critical: Avoid blocking this thread!
7. **1.raster (Raster Thread)**
   - Converts the Layer Tree into GPU-renderable commands.
   - Runs Skia graphics library (CPU-bound, but impacts GPU performance).
8. **DVSync-rs**
   - Provides VSync signals to the Render Service (RS) process.
9. **RenderService (RSUniRenderThread)**
   - Primary thread for RS rendering pipeline.
10. **RSHardwareThread**
    - Final stage of RS rendering before hardware submission.
11. **dpu_gfx_primary**
    - Hardware-accelerated DPU (Display Processing Unit) signal.

------

### **Key Takeaways**

- **Performance Optimization**: Focus on minimizing work on the **UI Thread** (1.ui) and optimizing rasterization (1.raster).
- **Frame Drops**: Investigate delays in **DVSync-app**, **mmi_service**, or GPU-related threads (e.g., `dpu_gfx_primary`).
- **Tooling**: Use trace analysis tools to visualize thread activity and identify bottlenecks.

Let me know if you need further refinements!