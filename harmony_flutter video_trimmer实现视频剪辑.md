# harmony_flutter video_trimmer实现视频剪辑

**简介**

videotrimmer是在OpenHarmony环境下，提供视频剪辑能力的三方库

**安装教程**

```
 ohpm install @ohos/videotrimmer
```

OpenHarmony ohpm环境配置等更多内容，请参考 [如何安装OpenHarmony ohpm包](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md) 。



**使用介绍**

构建VideoTrimmerOption对象:

```
 getContext(this).resourceManager.getMediaContent($r('app.media.app_icon'))
      .then(uint8 =>{
        let imageSource = image.createImageSource(uint8.buffer as any); // 步骤一：文件转为pixelMap 然后变换 给Image组件
        imageSource.createPixelMap().then(pixelmap => {
          this.videoTrimmerOption = {
            srcFilePath: this.filePath,
            listener:{
              onStartTrim: ()=>{
                console.log('dodo  开始裁剪')
                this.dialogController.open()
              },
              onFinishTrim:(path:string) => {
                console.log('dodo  裁剪成功 path='+path)
                this.outPath = path;
                this.dialogController.close()
              },
              onCancel:()=>{
                console.log('dodo  用户取消')
                router.replaceUrl({url:'pages/Index',params:{outFile: this.outPath}})
              }
            },
            loadFrameListener:{
              onStartLoad:()=>{
                console.log('dodo  开始获取帧数据')
                this.dialogController.open()
              },
              onFinishLoad:()=>{
                console.log('dodo  获取帧数据结束')
                this.dialogController.close()
              }
            },
            frameBackground: "#FF669900",
            framePlaceholder: pixelmap
          }
        })


      })
```



界面build()中使用VideoTrimmerView组件，传入VideoTrimmerOption对象

```
build() {
    Row() {
      Column() {
        VideoTrimmerView( {videoTrimmerOption:this.videoTrimmerOption!!})
      }
      .width('100%')
    }
    .height('100%')
  }
```



**参数说明**

**VideoTrimmerOption 视频剪辑选项**

| 字段              | 描述                               |
| ----------------- | ---------------------------------- |
| srcFilePath       | 视频源路径                         |
| listener          | 裁剪回调                           |
| loadFrameListener | 加载帧回调                         |
| VIDEO_MAX_TIME    | 指定裁剪长度 默认值10秒            |
| VIDEO_MIN_TIME    | 最小剪辑时间                       |
| MAX_COUNT_RANGE   | seekBar的区域内一共有多少张图片    |
| THUMB_WIDTH       | 裁剪视频预览长方形条状左右边缘宽度 |
| PAD_LINE_WIDTH    | 裁剪视频预览长方形条状上下边缘高度 |
| framePlaceholder  | 当加载帧没有完成，默认的占位图     |
| frameBackground   | 裁剪视频预览长方形条状区域背景颜色 |



**VideoTrimListener 视频剪辑回调**

| 方法名                           | 入参              | 接口描述 |
| -------------------------------- | ----------------- | -------- |
| onStartTrim();                   | 无                | 开始剪辑 |
| onFinishTrim(outputFile:string); | outputFile:string | 完成剪辑 |
| onCancel();                      | 无                | 取消剪辑 |

### 

**VideoLoadFramesListener 视频加载回调**

| 方法名          | 入参 | 接口描述       |
| --------------- | ---- | -------------- |
| onStartLoad();  | 无   | 开始加载视频帧 |
| onFinishLoad(); | 无   | 完成加载视频帧 |