# harmony_flutter  APNG用法

**简介**

ohos_apng是以开源库[apng-js](https://gitee.com/link?target=https%3A%2F%2Fgithub.com%2Fdavidmz%2Fapng-js)为参考，基于1.1.2版本，通过重构解码算法，拆分出apng里各个帧图层的数据；使用arkts能力，将每一帧数据组合成imagebitmap，使用定时器调用每一帧数据 通过canvas渲染，从而达到帧动画效果.对外提供解码渲染能力。

下载安装

```
ohpm install @ohos/apng
```



**使用说明**

```
  1、如果是在HSP模块中使用，可以使用两种方式传入Context上下文对象：
     1).在EntryAbility文件引入 import { GlobalContext } from '@ohos/apng'
        在onCreate函数中调用，传入上下文对象，用作后续读取本地图片资源文件
        示例：
        GlobalContext.getContext().setObject('MainContext',this.context);
      2).在使用组件的时候通过参数传入Context对象：
        示例：
         apngV2({
            src: $r('app.media.stack'),
            speedRate: this.speedRate,
            context: getContext()
          })
         apng({
            src: $r('app.media.stack'),
            speedRate: this.speedRate,
            context: getContext()
          })
```



```
2、引入 import {apng, ApngController} from '@ohos/apng';
  示例1：
    apngV2({
        src: $r('app.media.stack'), //图片资源
        speedRate: 1 //动画倍速
    })
    apng({
        src: $r('app.media.stack'), //图片资源
        speedRate: 1 //动画倍速
    })
  示例2：
    apngV2({
        src: 'https://gitee.com/openharmony-sig/ohos_apng/raw/master/entry/src/main/resources/base/media/stack.png', // 网络资源连接
        speedRate: 1 //动画倍速
    })
    apng({
        src: 'https://gitee.com/openharmony-sig/ohos_apng/raw/master/entry/src/main/resources/base/media/stack.png', // 网络资源连接
        speedRate: 1 //动画倍速
    })
    
 
  示例3：
    apngV2({
        src: this.srcUint8Array, // Uint8Array对象资源
        speedRate: 1 //动画倍速
    })
    apng({
        src: this.srcUint8Array, // Uint8Array对象资源
        speedRate: 1 //动画倍速
    })
    
  示例4：
    apngV2({
        src: getContext().filesDir + '/stack.png', // 沙箱路径
        speedRate: 1 //动画倍速
    })
    apng({
        src: getContext().filesDir + '/stack.png', // 沙箱路径
        speedRate: 1 //动画倍速
    })
  示例5：
    apngV2({
        src: $r('app.media.stack'),  //设置图片资源
        speedRate: this.speedRate, //设置动画倍速
        apngWidth: 200,  //设置动图的宽度
        apngHeight: 200  //设置动图的高度
    })
    apng({
        src: $r('app.media.stack'),  //设置图片资源
        speedRate: this.speedRate, //设置动画倍速
        apngWidth: 200,  //设置动图的宽度
        apngHeight: 200  //设置动图的高度
    })
  示例6：
    controller: ApngController = new ApngController();
    
    apngV2({
        src: $r('app.media.stack'),  //设置图片资源
        speedRate: this.speedRate, //设置动画倍速
        apngWidth: 200,  //设置动图的宽度
        apngHeight: 200  //设置动图的高度
        controller: this.controller
    })
    apng({
        src: $r('app.media.stack'),  //设置图片资源
        speedRate: this.speedRate, //设置动画倍速
        apngWidth: 200,  //设置动图的宽度
        apngHeight: 200  //设置动图的高度
        controller: this.controller
    })    

    this.controller.pause();
    this.controller.stop();
  示例7：
    aboutToAppear() {
        emitter.on("ohos-apng", (data) => {
          console.log('data', JSON.stringify(data))
        })
    }
```

```
 3、自定义内存缓存使用
    支持自定义内存缓存策略，支持设置内存缓存的大小(默认LRU策略)。
    Apng.getInstance().initMemoryCache()
    内存缓存默认关闭，开启/关闭内存缓存: 
    Apng.getInstance().setEnableCache(enableCache: boolean)
    清空全部内存缓存：
    Apng.getInstance().removeAllMemoryCache();
    清空指定内存缓存：
    Apng.getInstance().removeMemoryCache(src); 
    自定义内存缓存大小：
    Apng.getInstance().initMemoryCache(new MemoryLruCache(200, 128 * 1024 * 1024));
```