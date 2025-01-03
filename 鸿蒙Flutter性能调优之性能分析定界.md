# HarmonyOS next之鸿蒙Flutter性能调优之性能分析定界

flutter鸿蒙化的工程，也可以使用devtools对Dart代码进行调试.

**前置条件**

- OpenHarmony Next系统
- 前台运行Flutter页面
- 分析工具
  [DevEco Studio Profiler](https://developer.huawei.com/consumer/cn/download/)
  [SmartPerf](https://gitee.com/openharmony-sig/smartperf)



**Flutter线程介绍**

Flutter 使用多个线程来完成其必要的工作，图层中仅展示了其中两个线程。你写的所有 Dart 代码都在 UI 线程上运行。尽管你没有直接访问其他线程的权限，但是你对 UI 线程的操作会对其他线程产生性能影响。

- 平台线程  
平台的主线，插件代码在这里运行  

- UI 线程  
UI 线程在 Dart VM 中执行 Dart 代码。该线程包括开发者写下的代码和 Flutter 框架根据应用行为生成的代码。当应用创建和展示场景的时候，UI 线程首先建立一个 图层树（layer tree） ，一个包含设备无关的渲染命令的轻量对象，并将图层树发送到 GPU 线程来渲染到设备上。 不要阻塞这个线程！ 在性能图层的最低栏展示该线程。

- Raster 线程  
光栅化线程，又称GPU线程。raster 线程拿到 layer tree，并将它交给 GPU（图形处理单元）。你无法直接与 GPU 线程或其数据通信，但如果该线程变慢，一定是开发者 Dart 代码中的某处导致的。图形库 Skia 在该线程运行，并在性能图层的最顶栏显示该线程。请注意，raster 线程为 GPU 进行栅格化，而线程本身则是在 CPU 上运行的。

- I/O线程  
执行高负载的操作（常见的有 I/O）以避免阻塞 UI 或者 raster 线程。这个线程将不会显示在 performance overlay 上。

- RenderService线程  
RS进程的主线程，由Flutter渲染帧完成后，RS线程进行合成并送显.Texture模式下，Flutter渲染后的buffer与应用的主线程合成后，统一送显，受应用主线程的影响；Surface模式下，Flutter渲染帧单独送显，不受应用主线程影响。





**问题定界**

在DevEco Studio中点击下方的Profiler标签页，打开性能调优工具，抓取应用的trace后，收藏应用进程的&lt;x>.ui &lt;x>.raster 和RenderService的主线


![image-1-301](https://p.ipic.vip/dh0ed2.png)


上图的RenderService缺失帧，是因为UI线程单帧耗时较长，超过一帧的时间（120帧率下，一帧是8.33毫秒）。

![image-1-302](https://p.ipic.vip/pmgebf.png)


一帧渲染流程中，&lt;x>.ui 和 &lt;x>.raster加起来的的总时长超过一帧时间，则性能问题能定界是Flutter问题。问题的定位，需要进一步的性能分析。
