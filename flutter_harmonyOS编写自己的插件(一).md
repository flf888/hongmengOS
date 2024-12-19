# flutter_harmonyOS编写自己的插件(一)

### 一.注册自己的插件融入ohos工程

1.EntryAbility端代码

```
export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    flutterEngine.getPlugins()?.add(new ExamOhosUtilsPlugin());
  }
}
```

2.编写工具插件类 ExamOhosUtilsPlugin

```
/** ExamOhosUtilsPlugin **/
export default class ExamOhosUtilsPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private WXApi:wxopensdk.WXApi| null = null;
  private context:common.UIAbilityContext|null = null ;
  constructor() {
  }

  getUniqueClassName(): string {
    return "ExamOhosUtilsPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext() as common.UIAbilityContext;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "exam_ohos_utils");
    this.channel.setMethodCallHandler(this)

  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    console.log("onMethodCall==>" ,call.method);
    if (call.method == "getPlatformVersion") {
      //测试方法
      result.success("OpenHarmony ^ ^ ")
    } else {
      result.notImplemented()
    }
  }
}
```



3.flutter 创建调用工具类

```
class ExamOhosUtils {
  Future<String> getPlatformVersion() {
    return ExamOhosUtilsPlatform.instance.getPlatformVersion();
  }
}
```

```
/// An implementation of [ExamOhosUtilsPlatform] that uses method channels.
class MethodChannelExamOhosUtils extends ExamOhosUtilsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('exam_ohos_utils');

  @override
  Future<String> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
 }
```

```
abstract class ExamOhosUtilsPlatform extends PlatformInterface {
  /// Constructs a ExamOhosUtilsPlatform.
  ExamOhosUtilsPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExamOhosUtilsPlatform _instance = MethodChannelExamOhosUtils();

  /// The default instance of [ExamOhosUtilsPlatform] to use.
  ///
  /// Defaults to [MethodChannelExamOhosUtils].
  static ExamOhosUtilsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ExamOhosUtilsPlatform] when
  /// they register themselves.
  static set instance(ExamOhosUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
```

4.flutter端调用

```
ExamOhosUtils().aliPayAuth("").then((value) {
  print(value) ;
}) ;
```
