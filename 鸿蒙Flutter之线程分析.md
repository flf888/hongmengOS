##  鸿蒙Flutter之线程分析

**线程顺序**

- 掌握分析工具的使用后，便能去抓取Flutter应用的trace。trace中包含了应用运行期间的所有线程，需要先收藏下图的线程，以及按照图中线程的顺序去排序，才能更好的分析Flutter应用性能。下图每个线程的上方用数字标识了其排列的位置。  
- trace收藏线程，后收藏的线程会出现在收藏列表的顶部，所以实际收藏的时候，根据下图的倒序来收藏线程会比较方便。  
- 1）VSyncGennerator 2）DVSync-app 3）mmi_service 4）应用主线程 5）flutter'PointerEvent' 6）1.ui 7）1.raster 8）DVSync-rs 9）render_service 10）RSUniRenderThread 11）RSHardwareThread 12）dpu_gfx_primary

![image-2-201](https://p.ipic.vip/2ueyv5.png)

分析工具按顺序收藏线程后，线程收藏列表如下图：  
![image-2-202](https://p.ipic.vip/pumt1l.png)

![image-2-203](https://p.ipic.vip/5v10cw.png)

![image-2-204](https://p.ipic.vip/0rz887.png)



**收藏线程介绍**

- VSyncGennerator  
软件Vsync信号生成器，提供感知VSync帧的能力

- DVSync-app  
提供给app应用的软件Vsync信号

- mmi_service  
手指触摸屏幕时，触发的多模事件

- 应用主线程  
即线程号跟应用进程号一致，同时线程名跟进程名一致的主线程  
平台的主线，插件代码在这里运行

- flutter'PointerEvent'  
flutter的应用主线程发送触摸事件，到1.ui线程处理触摸事件的过程。这个线程可能会不存在。

- 1.ui  
UI线程，命名为< number >.ui  
UI 线程在 Dart VM 中执行 Dart 代码。该线程包括开发者写下的代码和 Flutter 框架根据应用行为生成的代码。当应用创建和展示场景的时候，UI 线程首先建立一个 图层树（layer tree） ，一个包含设备无关的渲染命令的轻量对象，并将图层树发送到 GPU 线程来渲染到设备上。 不要阻塞这个线程！ 在性能图层的最低栏展示该线程。

- 1.raster  
Raster线程，命名为< number >.raster  
raster 线程拿到 layer tree，并将它交给 GPU（图形处理单元）。你无法直接与 GPU 线程或其数据通信，但如果该线程变慢，一定是开发者 Dart 代码中的某处导致的。图形库 Skia 在该线程运行，并在性能图层的最顶栏显示该线程。请注意，raster 线程为 GPU 进行栅格化，而线程本身则是在 CPU 上运行的。

- DVSync-rs  
提供给RS进程的软件Vsync信号

- render_service  
RS进程的主线程，RS送显的第一步

- RSUniRenderThread  
RS进程的线程，RS送显的第二步

- RSHardwareThread  
RS进程的线程，RS送显的第三步

- dpu_gfx_primary  
硬件dpu信号