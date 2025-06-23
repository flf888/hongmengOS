# Flutter HarmonyOS Plugin Development Tutorial (Part 1)

------

## I. Registering Your Plugin in the OHOS Project

### 1. **EntryAbility Code**

Integrate the Flutter engine and register the plugin:

```
export default class EntryAbility extends FlutterAbility {
  @override
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    flutterEngine.getPlugins()?.add(new ExamOhosUtilsPlugin());
  }
}
```

------

### 2. **Plugin Implementation Class**

```
import { wxopensdk } from '@ohos.wxopensdk'; // Example dependency
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { common } from '@ohos.app.ability';

/** Custom Plugin for OHOS-Flutter Integration */
export default class ExamOhosUtilsPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private WXApi: wxopensdk.WXApi | null = null;
  private context: common.UIAbilityContext | null = null;

  constructor() {}

  getUniqueClassName(): string {
    return "ExamOhosUtilsPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext() as common.UIAbilityContext;
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "exam_ohos_utils");
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel) {
      this.channel.setMethodCallHandler(null);
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    console.log("onMethodCall ==> ", call.method);
    if (call.method === "getPlatformVersion") {
      result.success("HarmonyOS ^ ^");
    } else {
      result.notImplemented();
    }
  }
}
```

------

### 3. **Flutter Client Code**

#### a. Define the Plugin Interface

```
// Abstract class for platform-specific implementations
abstract class ExamOhosUtilsPlatform extends PlatformInterface {
  ExamOhosUtilsPlatform() : super(token: _token);

  static final Object _token = Object();

  static ExamOhosUtilsPlatform _instance = MethodChannelExamOhosUtils();

  static ExamOhosUtilsPlatform get instance => _instance;

  static set instance(ExamOhosUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion();
}

// Flutter plugin implementation using MethodChannel
class MethodChannelExamOhosUtils extends ExamOhosUtilsPlatform {
  final methodChannel = const MethodChannel('exam_ohos_utils');

  @override
  Future<String> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>('getPlatformVersion');
  }
}

// Client-facing utility class
class ExamOhosUtils {
  Future<String> getPlatformVersion() {
    return ExamOhosUtilsPlatform.instance.getPlatformVersion();
  }
}
```

------

### 4. **Flutter App Invocation**

```
// Trigger the plugin method
ExamOhosUtils().getPlatformVersion().then((version) {
  print("HarmonyOS Version: $version");
}).catchError((error) {
  print("Error: $error");
});
```

------

## Key Notes

1. **Plugin Registration**:
   - The `ExamOhosUtilsPlugin` must be registered in `EntryAbility` to handle method calls.
   - Use `MethodChannel` to define custom communication protocols.
2. **Native Integration**:
   - The OHOS-side code handles platform-specific logic (e.g., invoking Alipay SDK).
   - Flutter clients interact with the plugin via asynchronous method calls.
3. **Error Handling**:
   - Use `try/catch` blocks and `MethodResult` to handle exceptions gracefully.

