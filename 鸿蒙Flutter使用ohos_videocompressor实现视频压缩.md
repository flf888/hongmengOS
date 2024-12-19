##  鸿蒙Flutter使用ohos_videocompressor实现视频压缩

**介绍**

videoCompressor是一款ohos高性能视频压缩器。

目前实现的能力：支持视频压缩



**使用方法:**

有两种方式可以下载本工程：

1.开发者如果想要使用本工程,可以使用git命令

```
git clone https://gitee.com/openharmony-sig/ohos_videocompressor.git --recurse-submodules
```

2.点击下载按钮，把本工程下到本地，再把[third_party_bounds_checking_function](https://gitee.com/openharmony/third_party_bounds_checking_function)代码下载后，放入videoCompressor/src/cpp/boundscheck目录下，这样才可以编译通过。



下载安装

```
ohpm install @ohos/videocompressor
```



**具体使用方法:**

1.视频压缩接口展示:

```
let videoCompressor = new VideoCompressor();
videoCompressor.compressVideo(getContext(),this.selectFilePath,CompressQuality.COMPRESS_QUALITY_HIGH).then((data) => {
    if (data.code == CompressorResponseCode.SUCCESS) {
        console.log("videoCompressor HIGH message:" + data.message + "--outputPath:" + data.outputPath);
    } else {
        console.log("videoCompressor HIGH code:" + data.code + "--error message:" + data.message);
    }
    }).catch((err) => {
        console.log("videoCompressor HIGH get error message" + err.message);
    })
```



支持的视频规格:

mp4、mpeg.ts

视频解码类型:

AVC(H.264)、 HEVC(H.265)

支持的音频解码格式：

AAC



视频编码类型

AVC(H.264)、 HEVC(H.265)

支持的音频编码格式：AAC



**接口说明:**

视频压缩接口:

`compressVideo(context: Context, inputFilePath: string, quality: CompressQuality): Promise`

参数说明:

context:上下文，inputFilePath: 需要压缩的视频路径, quality: 压缩视频质量