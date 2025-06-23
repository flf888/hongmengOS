# HarmonyOS Flutter Alipay Plugin (Custom Payment Integration)

------

## I. MethodChannel Implementation

### 1. Flutter Code Implementation

**Define the MethodChannel and Handle Payment Responses**

```
/// Flutter plugin implementation using MethodChannel for Alipay integration
class MethodChannelExamOhosUtils extends ExamOhosUtilsPlatform {
  /// Method channel for communication with the native platform
  @visibleForTesting
  final methodChannel = const MethodChannel('exam_ohos_utils');

  @override
  Future<String> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<dynamic, dynamic>> aliPayAuth(String authParams) async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('aliPayAuth', authParams);
    return result;
  }
}
```

------

### 2. OHOS Code Implementation

**Integrate with Flutter Engine and Handle Alipay Payments**

```
import { Pay } from '@cashier_alipay/cashiersdk';
import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import { BusinessError } from '@kit.BasicServicesKit';

/** Alipay Plugin for HarmonyOS Flutter Integration */
export default class ExamOhosUtilsPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  constructor() {}

  getUniqueClassName(): string {
    return "ExamOhosUtilsPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "exam_ohos_utils");
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      if (call.method === "getPlatformVersion") {
        // Test method to return platform version
        result.success("OpenHarmony ^ ^");
      } else if (call.method === "aliPayAuth") {
        // Handle Alipay payment
        const payResult = await new Pay().pay(call.args as string, true);
        result.success(payResult);
      } else {
        result.notImplemented();
      }
    } catch (error) {
      const errorMap = new Map<string, string>();
      errorMap.set("resultCode", "-1");
      errorMap.set("errorMsg", error.message || "Payment failed");
      result.success(errorMap);
    }
  }
}
```

------

## II. Alipay Integration Workflow

### **1. Initialize the Plugin**

```
// Register the plugin in your Flutter app
final examOhosUtils = MethodChannelExamOhosUtils();
```

### **2. Trigger Alipay Payment**

```
// Prepare payment parameters (JSON string)
const authParams = '{"orderNo":"123456","amount":99.99}';

// Call the Alipay payment method
examOhosUtils.aliPayAuth(authParams).then((response) {
  if (response["resultCode"] == "9000") {
    print("Payment successful!");
  } else {
    print("Payment failed: ${response["errorMsg"]}");
  }
}).catchError((err) {
  print("Payment error: $err");
});
```

------

## III. Key Features

- **Seamless Integration**: Uses Alipay's official SDK for secure payments.
- **Asynchronous Handling**: Supports non-blocking payment flows with Futures.
- **Error Handling**: Provides detailed error codes and messages for debugging.

