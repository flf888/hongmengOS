# harmony_flutter_qrcode(生成二维码) 

### 一.MethodChannel

1.flutter端代码

- 创建MethodChannel
- 接收ohos端传递过来的状态值

```
 class RecognitionManager {
  static const MethodChannel _channel =
      const MethodChannel('recognition_qrcode');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> setConfig({
    String? icon,
    double? iconWidth = 30,
    double? iconHeight = 30,
    double? cancelTitleFontSize = 16,
    String? cancelTitle = "取消",
  }) async {
    Map<String, dynamic> map = {
      "iconWidth": iconWidth ?? 30,
      "iconHeight": iconHeight ?? 30,
      "cancelTitleFontSize": cancelTitleFontSize ?? 16,
      "cancelTitle": cancelTitle ?? "取消",
    };
    try {
      if (icon != null) {
        ByteData byteData = await rootBundle.load(icon);
        ByteBuffer buffer = byteData.buffer;

        map["icon"] = Uint8List.view(buffer);
      }
    } catch (e) {
      print("RecognitionQrcode.config: Failed to get image");
    }
    await _channel.invokeMethod("setConfig", map);
  }

  // base64 || url || file path
  static Future<RecognitionResult> recognition(dynamic img) async {
    var res = await _channel.invokeMethod('recognitionQrcode', img);
    RecognitionResult result = RecognitionResult(
      code: res["code"],
      value: res["value"],
    );
    return result;
  }
}
```



2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建MethodChannel实例device_util
- setMethodCallHandler
- 通过result回传参数

```
 private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;
  private ability: UIAbility | null = null;
  private config: Map<string, ESObject> = new Map();

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult) {
    if (call.method === "getPlatformVersion") {
      Log.d(TAG, deviceInfo.osFullName)
      result.success("Ohos " + deviceInfo.sdkApiVersion);
    } else if (call.method === 'setConfig') {
      this.config = call.args;
      if(call.args.get('icon')) {
        const image: Uint8Array = call.args.get('icon');
        const url: string | null = this.saveCacheDir(image.buffer);
        this.config.set('icon', url)
      }

      Log.d(TAG, JSON.stringify(call.args))
      result.success(null);
    } else if (call.method === 'recognitionQrcode') {
      let url: string | null = call.args;
      if(url?.includes('http') || url?.includes('https')) {
        url = await this.downloadHttpImage(call.args);
      } else if(!url?.includes('/data/') && this.base64Decode(this.base64Encode(url as string)) == url) {
        url = this.saveCacheDir(buffer.from(url, 'base64').buffer)
      }

      if(!url) return;

      // 定义识码参数inputImage，其中uri为picker选择图片
      let inputImage: detectBarcode.InputImage = { uri: url }
      // 定义识码参数options
      let options: scanBarcode.ScanOptions = {
        scanTypes: [scanCore.ScanType.ALL],
        enableMultiMode: true,
        enableAlbum: true
      }

      // 调用图片识码接口
      this.decodeImage(inputImage, options, result)
    } else {
      result.notImplemented()
    }
  }

```



通过@ohos 原生库生成二维码

```
 base64Encode(value: string) {
    let base64Helper = new util.Base64Helper();
    let texEncoder = util.TextEncoder.create("utf-8");
    return base64Helper.encodeToStringSync(texEncoder.encodeInto(value));
  }

  base64Decode(value: string) {
    let base64Helper = new util.Base64Helper();
    let texEncoder = util.TextDecoder.create("utf-8");
    return texEncoder.decodeWithStream(base64Helper.decodeSync(value));
  }

  decodeImage(inputImage: detectBarcode.InputImage, options: scanBarcode.ScanOptions, result: MethodResult) {
    detectBarcode.decode(inputImage, options).then((r: Array<scanBarcode.ScanResult>) => {
      Log.d(TAG, JSON.stringify(r));
      if (r.length > 1) {
        this.openAbility(r, inputImage.uri, result)
      } else if (r.length === 1) {
        result.success({
          code: "0",
          value: r[0].originalValue,
          result: r  // 暴露给flutter让用户处理
        });
      } else {
        result.error("-1", "Image parsing failed", null);
      }

    }).catch((failResult: BusinessError) => {
      Log.d(TAG, JSON.stringify(failResult));
      result.error("-1", "Image parsing failed", null);
    });
  }
```
