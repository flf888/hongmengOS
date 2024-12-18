##  鸿蒙Flutter性能调优性能分析之帧渲染跟踪

Flutter应用进行性能分析时，需利用分析工具捕获应用的trace数据，并对其进行分析。鉴于Flutter应用中可能会出现需要单独追踪某帧渲染的情况，如帧率卡顿或帧丢失，本文特介绍了一种针对单帧追踪的方法。   


## 分析工具
常用的分析工具包括[DevEco Studio Profiler](https://developer.huawei.com/consumer/cn/download/)及[SmartPerf](https://gitee.com/openharmony-sig/smartperf)，建议选用DevEco Studio Profiler性能调优工具。性能调优工具DevEco Studio Profiler的使用方法可查看[DevEco Profiler工具简介](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/deep-recording-V5).


## 帧标识
一帧的渲染流程大致如下：

![image-3-201](https://p.ipic.vip/vnhk7j.png)

掌握帧渲染流程非常重要，同时也需要掌握帧渲染流程的每个单元的匹配。为每个单元寻找一个合适的标识符，能正确匹配渲染流程。

### 第一个标识 frame_number
1.ui和1.raster之间联系的标识符是frame_number。  
收藏该两个线程，将这两个线程关联起来进行观察，会在trace上找到这个标识符，这是Flutter应用帧渲染的第一个标识符。  

- 如果frame_number的标识符未在1.ui和1.raster中出现，表明当前帧不是flutter自渲染，需要重新定界性能问题。



![image-3-202](https://p.ipic.vip/wemh64.png)

### 第二个标识 ReuseBuffer/acquire buffer

1.raster和render_service之间联系的标识符是ReuseBuffer。  
在1.raster线程"flutter::SkCanvas::Flush"的trace过程中，会向RS进程申请buffer内存，用于存储渲染的帧内容。点击"binder transaction"的trace可以跳转到另一个线程，查看对应的ReuseBuffer的id。

![image-3-203](https://p.ipic.vip/xsvlq5.png)


在render_service线程"RSMainThread::DoComposition"的trace过程中，会获取buffer内存里的帧内存。"acquire buffer sequence"的trace里就能看到和1.raster线程申请的ReuseBuffer编号是一样的。

![image-3-204](https://p.ipic.vip/xspzep.png)



- 通过上面展示的两个标识，就能识别flutter应用到RS进程上的帧渲染。而RS进程上后面的单元是怎么识别的，目前还没有直观的trace可以看到，默认连续的线程trace是同一帧（即render_service到RSUniRenderThread，再到RSHardwareThread是连续的）。