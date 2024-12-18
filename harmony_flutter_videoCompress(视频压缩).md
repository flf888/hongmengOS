# harmony_flutter_videoCompress(视频压缩) 

### 一.MethodChannel

1.flutter端代码

- 创建MethodChannel交互通道video_compress
- 接收ohos端传递过来的进度

```
  final compressProgress$ = ObservableBuilder<double>();
  final _channel = const MethodChannel('video_compress');

  @protected
  void initProcessCallback() {
    _channel.setMethodCallHandler(_progressCallback);
  }

  MethodChannel get channel => _channel;

  bool _isCompressing = false;

  bool get isCompressing => _isCompressing;

  @protected
  void setProcessingStatus(bool status) {
    _isCompressing = status;
  }

  Future<void> _progressCallback(MethodCall call) async {
    switch (call.method) {
      case 'updateProgress':
        final progress = double.tryParse(call.arguments.toString());
        if (progress != null) compressProgress$.next(progress);
        break;
    }
  }
```

```
封装请求方法，传递压缩参数
final jsonStr = await _invoke<String>('compressVideo', {
  'path': path,
  'quality': quality.index,
  'deleteOrigin': deleteOrigin,
  'startTime': startTime,
  'duration': duration,
  'includeAudio': includeAudio,
  'frameRate': frameRate,
});
```

2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建MethodChannel实例video_compress
- onMethodCall回调中监听回调方法（名字需要与flutter端保持一致）
- 通过MethodResult回传参数

```
const CHANNEL_NAME = "video_compress";

private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;
  private ability: UIAbility | null = null;
  private unity: Unity | null = null;
  private videoCompress: VideoCompress | null = null;

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, "onAttachedToAbility");
    this.ability = binding.getAbility();
    this.unity = new Unity(this.ability.context);
    this.videoCompress = new VideoCompress(this.ability.context);
  }

  onDetachedFromAbility(): void {
    Log.i(TAG, "onDetachedFromAbility");
    this.ability = null;
  }

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
  
  onMethodCall(call: MethodCall, result: MethodResult): void {
    Log.d(TAG, "call: " + call.method)

    try {
      switch (call.method) {
        case 'compressVideo': {
          const path = call.argument("path") as string;
          const quality = call.argument("quality") as number;
          const deleteOrigin = call.argument("deleteOrigin") as boolean;
          const startTime = call.argument("startTime") as number;
          const duration = call.argument("duration") as number;

          Log.d(TAG, JSON.stringify({
            path,
            quality,
            deleteOrigin,
            startTime,
            duration
          }))
          Log.d(TAG, path)

          let includeAudio = call.argument("includeAudio") as boolean | undefined;
          if (includeAudio === undefined) {
            includeAudio = true;
          }

          let frameRate = call.argument("frameRate") as number | undefined;
          if (frameRate === undefined) {
            frameRate = 30;
          }

          const tempDir = this.applicationContext!.tempDir;
          const out: string = dayjs().format('YYYY-MM-DD HH-mm-ss');
          const destPath: string = tempDir + "/VID_" + out + ".mp4";

          Log.d(TAG, destPath)

          this.methodChannel?.invokeMethod("updateProgress", 1)
          this.videoCompress?.compress(path, quality).then(out => {
            if (deleteOrigin) {
              fs.unlinkSync(path);
            }
            this.unity?.getMediaInfoJson(out).then((json) => {
              Log.d(TAG, JSON.stringify(json))
              json['isCancel'] = false;
              this.methodChannel?.invokeMethod("updateProgress", 100)
              result.success(JSON.stringify(json))
            })
          })
          break;
        }
        default:
          result.notImplemented()
      }
    } catch (err) {
      result.error("Name not found", err.message, null)
    }
  }
```



