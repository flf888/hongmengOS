##  鸿蒙Flutter性能调优之滑动响应时延

本篇文章针对flutter应用的滑动场景，进行响应时延的trace分析。

**手指按下**

手指按下是所有点击或滑动事件的大前提，可以知道手指坐标的初始位置和触摸哪个控件等重要信息。


mmi_service线程负责触发多模交互事件，由Flutter应用监听和响应触摸事件。


手指按下的触摸事件，会立即转发给Flutter应用。

在mmi_service线程的"package touchEvent"的trace后面的下一个trace，可以看到"service report touchId:编号, type: down"的trace，type为down，说明是手指按下的触摸事件。而在应用主线程，有"DispatchTouchEvent"的trace，上面有详细坐标打印和触摸事件类型，type数值为0，说明是手指按下的触摸事件。这两个线程上的trace是对应的。

![image-4-201](https://p.ipic.vip/1gwbf7.png)



**手指滑动**

手指滑动的触摸事件，不会立即转发给Flutter应用，而是由vsync-app信号来控制发送。


和手指按下的trace一样，mmi_service线程和应用主线程都有一样的trace可以对应，只是type类型不一样。type为move，数值为2。

手指滑动的触摸事件需通过flutterSyncName的vsync-app信号触发，之后才能传递到flutter应用主线程。因此，时间顺序是，mmi_service到VSyncGennerator，再到DVSync-app，最后到应用主线程。trace顺序如下图：

![image-4-301](https://p.ipic.vip/2eej52.png)

- 注意：第一个手指滑动的触摸事件的坐标点和手指按下的触摸事件的坐标点是一样的。



**滑动阈值 TouchSlop**

TouchSlop是系统所能识别的滑动的最小距离,是一个阈值，称为滑动阈值。用户可以自定义设置控件的滑动阈值，系统默认值是18。

那么通过查看应用主线程的触摸事件trace的坐标，可以自行计算坐标偏移量是否达到滑动阈值。

4.滑动首帧
当手指滑动的触摸事件的滑动距离超过设定的滑动阈值时，Flutter应用会触发update操作。但是，实际的绘制操作需要等待下一帧的到来才能执行。所以滑动开始的第一帧渲染，会在触摸事件满足滑动条件后，还需等待一帧的延迟。

trace如下图：

![image-4-401](https://p.ipic.vip/fgg8jt.png)



**首帧渲染**

渲染的大致过程看[性能分析-帧渲染跟踪](./performance-frame-rendering-tracking.md)，需要准确找到对应的trace。

帧渲染的结束是在RS进程的RSHardwareThread线程上，但是在自动化测试的时候，帧渲染的结束标识是dpu_gfx_primary线程。（dpu_gfx_primary只是一个硬件信号，不详细讲解）

trace如下图：

![image-4-501](https://p.ipic.vip/qfsm73.png)


所以从mmi_service线程的手指按下的trace开始，到滑动首帧渲染结束，这花费的时间就是滑动响应时延。