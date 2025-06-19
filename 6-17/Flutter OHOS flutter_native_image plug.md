
# flutter_native_image

Native Flutter Image Processing Plugin

This plugin provides native tools for resizing images and reducing their quality through compression. While the implementation may be somewhat rough (especially the iOS portion), it's reliable for essential needs and maintains stability. Contributions for improvements are welcome.

## Usage

### Installation

Add the following line to your `pubspec.yaml` under dependencies:

    ```yaml
    dependencies:
      flutter_native_image: ^0.0.6
    ```

### Compress Images

    ```dart
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
    quality: quality, percentage: percentage);
    ```

Provide a filesystem path and optionally specify:
- `quality` (1-100, default preserves original)
- `percentage` (1-100 resize percentage)

To resize to specific dimensions:

    ```dart
    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
    File compressedFile = await FlutterNativeImage.compressImage(file.path, quality: 80, 
    targetWidth: 600, targetHeight: 300);
    ```

Maintain aspect ratio:

    ```dart
    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
    File compressedFile = await FlutterNativeImage.compressImage(file.path, quality: 80, 
    targetWidth: 600, 
    targetHeight: (properties.height * 600 / properties.width).round());
    ```

### Get Image Properties
    ```dart
    ImageProperties properties = await FlutterNativeImage.getImageProperties(file.path);
    ```
Returns an object containing image width, height, and orientation.

### Crop Images
    ```dart
    File croppedFile = await FlutterNativeImage.cropImage(file.path, originX, originY, width, height);
    ```
Returns a new file with the image cropped to specified dimensions.

### HarmonyOS Implementation (FlutterNativeImagePlugin.ets)

    ```typescript
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
    
    /** FlutterNativeImagePlugin Implementation **/
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
      let targetWidth: number = call.argument("targetWidth") || 0
      let targetHeight: number = call.argument("targetHeight") || 0
      let quality: number = call.argument("quality")
    
      if(!fs.accessSync(fileName)) {
    result.error("file does not exist", fileName, null)
    return
      }
    
      try {
    let contextImage: image.ImageSource = image.createImageSource(fileName)
    let contextImageInfo: image.ImageInfo = await contextImage.getImageInfo()
    
    let newWidth: number = targetWidth || (contextImageInfo.size.width * resizePercentage / 100)
    let newHeight: number = targetHeight || (contextImageInfo.size.height * resizePercentage / 100)
    
    let scaleX: number = newWidth / contextImageInfo.size.width
    let scaleY: number = newHeight / contextImageInfo.size.height
    
    let bmp: image.PixelMap = await contextImage.createPixelMap()
    const imagePackerApi = image.createImagePacker()
    let packOpts: image.PackingOption = { format: "image/jpeg", quality: quality }
    
    await bmp.scale(scaleX, scaleY)
    
    let bos: ArrayBuffer = await imagePackerApi.packing(bmp, packOpts)
    
    if(this.context) {
      let outputFileName: string = `${this.context.cacheDir}/${this.getFilenameWithoutExtension(fileName)}_compressed${util.generateRandomUUID(true)}.jpg`
    
      let newFile = fs.openSync(outputFileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      fs.writeSync(newFile.fd, bos)
      fs.closeSync(newFile)
    
      await this.copyExif(fileName, outputFileName)
    
      result.success(outputFileName)
      return
    }
      } catch (e) {
    result.error("Processing failed", e.message, null)
      }
    }
    
    if(call.method == "getImageProperties") {
      // ... (implementation details) ...
    }
    
    if(call.method == "cropImage") {
      // ... (implementation details) ...
    }
    
    if(call.method == "getPlatformVersion") {
      result.success("HarmonyOS: " + deviceInfo.buildVersion)
    } else {
      result.notImplemented()
    }
      }
    
      private getFilenameWithoutExtension(fileName: string) {
    return fileName.lastIndexOf('.') > 0 
      ? fileName.substring(0, fileName.lastIndexOf('.')) 
      : fileName
      }
    
      async copyExif(originalPath: string, newPath: string): Promise<void> {
    try {
      // Preserves EXIF metadata during processing
      // ... (implementation details) ...
    } catch (e) {
      Log.e("FlutterNativeImagePlugin", "Error preserving EXIF data: " + e)
    }
      }
    }
    ```