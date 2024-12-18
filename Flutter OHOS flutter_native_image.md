
# flutter_native_image

原生 Flutter 图片工具

此插件旨在提供原生工具来调整图像大小并通过压缩降低其质量。代码有点粗糙（尤其是 iOS 部分），但它可以满足我的需求，并且从未崩溃过。如果您愿意，请随意改进它。

## 用法

### 安装

在依赖项下的 pubspec.yaml 中添加以下几行


    flutter_native_image: ^0.0.6


### 压缩图像

    File compressedFile = await FlutterNativeImage.compressImage(file.path,
    quality: quality, percentage: percentage);


您必须从文件系统中为其提供一个文件，并可选地提供质量 (1-100) 和调整大小百分比 (1-100)。每个平台都会使用其适当的工具来处理调整大小。

要将图像调整为特定尺寸，请使用以下代码：
    
    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
    File compressedFile = await FlutterNativeImage.compressImage(file.path, quality: 80, 
    targetWidth: 600, targetHeight: 300);

保持文件的纵横比：

    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
    File compressedFile = await FlutterNativeImage.compressImage(file.path, quality: 80, 
    targetWidth: 600, 
    targetHeight: (properties.height * 600 / properties.width).round());

### 获取图像属性
    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);

它返回一个包含图像宽度和高度的 ImageProperties 对象。

### 裁剪图像
    File croppedFile = await FlutterNativeImage.cropImage(file.path, originX, originY, width, height);

返回包含按给定尺寸裁剪的图像的文件。

### 鸿蒙实现代码 FlutterNativeImagePlugin.ets

    /**
     * Copyright (c) 2024 Huawei Device Co., Ltd.
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     * http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     */
    
    import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
    import MethodChannel, { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
    import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
    import image from '@ohos.multimedia.image';
    import fs from '@ohos.file.fs';
    import common from '@ohos.app.ability.common';
    import { Log } from '@ohos/flutter_ohos';
    import deviceInfo from '@ohos.deviceInfo';
    import  { BusinessError } from '@ohos.base';
    import util from '@ohos.util';
    
    /** FlutterNativeImagePlugin **/
    export default class FlutterNativeImagePlugin implements FlutterPlugin, MethodCallHandler {
      private channel: MethodChannel | null = null;
      private context: common.Context | null = null;
      private pluginBinding: FlutterPluginBinding | null = null;
    
      constructor(context?: common.Context) {
    if(context) {
      this.context = context
    }
      }
    
      setUp(context: common.Context) {
    this.context = context;
      }
    
      getUniqueClassName(): string {
    return "FlutterNativeImagePlugin"
      }
    
      onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_native_image");
    this.channel.setMethodCallHandler(this)
    this.pluginBinding = binding
    if(this.pluginBinding) {
      this.setUp(this.pluginBinding.getApplicationContext())
    }
      }
    
      onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
      }
    
      async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    if(call.method == "compressImage") {
      let fileName: string = call.argument("file")
      let resizePercentage: number = call.argument("percentage")
      let targetWidth: number = call.argument("targetWidth") == null ? 0 : call.argument("targetWidth")
      let targetHeight: number = call.argument("targetHeight") == null ? 0 : call.argument("targetHeight")
      let quality: number = call.argument("quality")
    
      if(!fs.accessSync(fileName)) {
    result.error("file does not exist", fileName, null)
    return
      }
    
      let file: fs.File = fs.openSync(fileName);
    
      let contextImage: image.ImageSource = image.createImageSource(fileName)
      let contextImageInfo: image.ImageInfo = await contextImage.getImageInfo()
    
      let newWidth: number = targetWidth == 0 ? (contextImageInfo.size.width / 100 * resizePercentage): targetWidth
      let newHeight: number = targetHeight == 0 ? (contextImageInfo.size.height / 100 * resizePercentage): targetHeight
    
      let scaleX: number = newWidth / contextImageInfo.size.width
      let scaleY: number = newHeight / contextImageInfo.size.height
    
      let bmp: image.PixelMap = await contextImage.createPixelMap()
      const imagePackerApi = image.createImagePacker()
      let packOpts: image.PackingOption = { format: "image/jpeg", quality: quality }
    
      await bmp.scale(scaleX, scaleY)
    
      let bos: ArrayBuffer = await imagePackerApi.packing(bmp, packOpts)
    
      try{
    if(this.context) {
      let outputFileName: string = this.context.cacheDir + "/" + this.getFilenameWithoutExtension(file).concat("_compressed" + file.fd + util.generateRandomUUID(true)) + ".jpg"
    
      let newFile = fs.openSync(outputFileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.write(newFile.fd, bos, (err: BusinessError, writeLen: number) => {
    if(err) {
      console.error("write data to file failed with error message: " + err.message + ",error code:" + err.code)
    } else {
      console.info("write data to file succeed and size is:" + writeLen)
    }
    fs.closeSync(newFile)
      })
    
      this.copyExif(fileName, outputFileName)
    
      result.success(outputFileName)
    }
    
    result.error("context initialization failed", fileName, null)
    return
      } catch (e) {
    e.printStackTrace();
      }
    
      return
    }
    if(call.method == "getImageProperties") {
      let fileName: string = call.argument("file")
    
      if(!fs.accessSync(fileName)) {
    result.error("file does not exist", fileName, null)
    return
      }
    
      let imageInfo: image.ImageInfo = await image.createImageSource(fileName).getImageInfo()
      let properties: Map<string, number> = new Map<string, number>()
      properties.set("width", imageInfo.size.width)
      properties.set("height", imageInfo.size.height)
    
      let orientation: number = 1
      try{
    let imageOrientation: string = await image.createImageSource(fileName).getImageProperty(image.PropertyKey.ORIENTATION)
    if(imageOrientation != null && imageOrientation != "") {
      switch (imageOrientation){
    case "Top-left":
      orientation = 1
      break
    case "Top-right":
      orientation = 2
      break
    case "Bottom-right":
      orientation = 3
      break
    case "Bottom-left":
      orientation = 4
      break
    case "Left-top":
      orientation = 5
      break
    case "Right-top":
      orientation = 6
      break
    case "Right-bottom":
      orientation = 7
      break
    case "Left-bottom":
      orientation = 8
      break
    default:
      orientation = 0
      break
      }
    }
      } catch (e) {
    
      }
    
      properties.set("orientation", orientation)
    
      result.success(properties)
      return
    }
    if(call.method == "cropImage") {
      let fileName: string = call.argument("file")
      let originX: number = call.argument("originX")
      let originY: number = call.argument("originY")
      let widthNumber: number = call.argument("width")
      let heightNumber: number = call.argument("height")
    
      if(!fs.accessSync(fileName)) {
    result.error("file does not exist", fileName, null)
    return
      }
    
      let file: fs.File = fs.openSync(fileName)
    
      let contextImage: image.ImageSource = image.createImageSource(fileName)
      let bmp: image.PixelMap = await contextImage.createPixelMap()
    
      try{
    await bmp.crop({x: originX, y: originY, size: { height: heightNumber, width: widthNumber}})
      } catch (e) {
    e.printStackTrace()
    result.error("bounds are outside of the dimensions of the source image", fileName, null)
      }
    
      const imagePackerApi = image.createImagePacker()
      let packOpts: image.PackingOption = { format: "image/jpeg", quality: 100 }
      let bos: ArrayBuffer = await imagePackerApi.packing(bmp, packOpts)
    
      try{
    if(this.context) {
      let outputFileName: string = this.context.cacheDir + "/" + this.getFilenameWithoutExtension(file).concat("_cropImage" + file.fd + util.generateRandomUUID(true)) + ".jpg"
    
      let newFile = fs.openSync(outputFileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.write(newFile.fd, bos, (err: BusinessError, writeLen: number) => {
    if(err) {
      console.error("write data to file failed with error message: " + err.message + ",error code:" + err.code)
    } else {
      console.info("write data to file succeed and size is:" + writeLen)
    }
    fs.closeSync(newFile)
      })
    
      this.copyExif(fileName, outputFileName)
    
      result.success(outputFileName)
    }
    
    result.error("context initialization failed", fileName, null)
    return
      } catch (e) {
    e.printStackTrace()
    result.error(e + " went wrong", fileName, null)
      }
    
      return
    }
    if(call.method == "getPlatformVersion") {
      result.success("ohos: " + deviceInfo.buildVersion)
    } else {
      result.notImplemented()
    }
      }
    
      private getFilenameWithoutExtension(_file: fs.File) {
    let fileName: string = _file.name
    
    if(fileName.indexOf(".") > 0){
    return fileName.substring(0, fileName.lastIndexOf("."))
    } else {
    return fileName
    }
      }
    
      async copyExif(filePathOri: string, filePathDest: string): Promise<void> {
    try {
      let oldExif: image.ImageSource = image.createImageSource(filePathOri)
      let newExif: image.ImageSource = image.createImageSource(filePathDest)
      let propertyKey: image.PropertyKey[] = [
    image.PropertyKey.F_NUMBER,
    image.PropertyKey.EXPOSURE_TIME,
    image.PropertyKey.ISO_SPEED,
    image.PropertyKey.FOCAL_LENGTH,
    image.PropertyKey.GPS_DATE_STAMP,
    image.PropertyKey.WHITE_BALANCE,
    image.PropertyKey.GPS_TIME_STAMP,
    image.PropertyKey.DATE_TIME,
    image.PropertyKey.FLASH,
    image.PropertyKey.GPS_LATITUDE,
    image.PropertyKey.GPS_LATITUDE_REF,
    image.PropertyKey.GPS_LONGITUDE,
    image.PropertyKey.GPS_LONGITUDE_REF,
    image.PropertyKey.MAKE,
    image.PropertyKey.MODEL,
    image.PropertyKey.ORIENTATION,
      ]
    
      propertyKey.forEach(async (value) => {
    let keyValue: string = await oldExif.getImageProperty(value)
    await newExif.modifyImageProperty(value, keyValue)
      })
    } catch (e) {
      Log.e("FlutterNativeImagePlugin", "Error preserving exif data on selected image: " + e)
    }
      }
    }