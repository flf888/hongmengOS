# HarmonyOS Flutter: Simplified WeChat Pay Integration

------

## I. Configure HarmonyOS Application Information

### **Important Notes**

Refer to the official WeChat Pay documentation:
 [https://pay.weixin.qq.com/doc/v3/merchant/4012073588#%E9%B8%BF%E8%92%99-SDK-%E8%B0%83%E7%94%A8%E8%AF%B4%E6%98%8E](https://pay.weixin.qq.qq.com/doc/v3/merchant/4012073588#鸿蒙-SDK-调用说明)

**Key Configuration Requirements**:

1. **Bundle ID**: The package name of your HarmonyOS app.
2. **Identifier**: Your app’s unique identifier (App ID obtained from WeChat Open Platform).

**Critical Warning**:

- If your app is already published on Android/iOS markets, **do not select "Not published on any market"**. This option restricts WeChat Pay functionality unless all platforms (Android, iOS, HarmonyOS) are unpublished.

------

## II. SDK Dependency Configuration

```
{
  "name": "demo",
  "version": "1.0.0",
  "description": "Describe the basic app info.",
  "main": "",
  "author": "",
  "license": "",
  "dependencies": {
    "@tencent/wechat_open_sdk": "1.0.0" // WeChat Open SDK dependency
  }
}
```

------

## III. Ohos-Side Integration

### **1. Initialize WeChat API**

```
import * as wxopensdk from '@wechat/open_sdk';

// Create WXAPI instance with your App ID
export const WXApi = wxopensdk.WXAPIFactory.createWXAPI(APP_ID);

// Define callback handler for WeChat responses
class WXApiEventHandlerImpl implements wxopensdk.WXApiEventHandler {
  private onReqCallbacks = new Map<OnWXReq, OnWXReq>();
  private onRespCallbacks = new Map<OnWXResp, OnWXResp>();

  registerOnWXReqCallback(on: OnWXReq) {
    this.onReqCallbacks.set(on, on);
  }

  unregisterOnWXReqCallback(on: OnWXReq) {
    this.onReqCallbacks.delete(on);
  }

  registerOnWXRespCallback(on: OnWXResp) {
    this.onRespCallbacks.set(on, on);
  }

  unregisterOnWXRespCallback(on: OnWXResp) {
    this.onRespCallbacks.delete(on);
  }

  onReq(req: wxopensdk.BaseReq) {
    Log.i(kTag, `onReq: ${JSON.stringify(req)}`);
    this.onReqCallbacks.forEach((callback) => callback(req));
  }

  onResp(resp: wxopensdk.BaseResp) {
    Log.i(kTag, `onResp: ${JSON.stringify(resp)}`);
    this.onRespCallbacks.forEach((callback) => callback(resp));
  }
}

export const WXEventHandler = new WXApiEventHandlerImpl();
```

### **2. Initiate Payment**

```
// Build payment request
let req = new wxopensdk.PayReq();
req.appId = 'wxd930ea5d5a258f4f'; // Your WeChat App ID
req.partnerId = '1900000109'; // Your WeChat Merchant ID
req.prepayId = '1101000000140415649af9fc314aa427'; // Prepay ID from WeChat Pay API
req.packageValue = 'Sign=WXPay'; // Fixed value
req.nonceStr = '1101000000140429eb40476f8896f4c9'; // Random string (≤32 chars)
req.timeStamp = '1398746574'; // Timestamp
req.sign = '7FFECB600D7157C5AA49810D2D8F28BC2811827B'; // Signature

// Send payment request to WeChat
let finished = await WXApi.sendReq(
  context: common.UIAbilityContext, // Required for inter-app navigation
  req: req
);
```

------

## IV. Flutter Plugin Channel Setup

### **1. Flutter Side Implementation**

```
class WeChatPayPlugin {
  static const MethodChannel _channel = MethodChannel('wechat_pay');

  // Initialize WeChat API
  Future<bool> registerWxApi(String appId) async {
    return await _channel.invokeMethod('registerWxApi', appId);
  }

  // Trigger WeChat Pay
  Future<bool> payWithWeChat({
    required String appId,
    required String partnerId,
    required String prepayId,
    required String packageValue,
    required String nonceStr,
    required int timeStamp,
    required String sign,
    String? signType,
    String? extData,
  }) async {
    return await _channel.invokeMethod('payWithWeChat', {
      'appId': appId,
      'partnerId': partnerId,
      'prepayId': prepayId,
      'packageValue': packageValue,
      'nonceStr': nonceStr,
      'timeStamp': timeStamp,
      'sign': sign,
      'signType': signType,
      'extData': extData,
    });
  }
}
```

------

## V. External Invocation Example

```
// Call WeChat Pay from Flutter
WeChatPayPlugin().payWithWeChat(
  appId: itemMap['appid'].toString(),
  partnerId: itemMap['partnerid'].toString(),
  prepayId: itemMap['prepayid'].toString(),
  packageValue: itemMap['package'].toString(),
  nonceStr: itemMap['noncestr'].toString(),
  timeStamp: int.parse(itemMap['timestamp']),
  sign: itemMap['sign'].toString(),
).then((success) {
  print('--- Payment Result: $success');
});
```

------

## VI. Key Notes

1. **Lifecycle Handling**:

   - In your HarmonyOS 

     ```
     EntryAbility
     ```

     , override 

     ```
     onCreate
     ```

      and 

     ```
     onNewWant
     ```

      to handle WeChat callbacks:

     ```
     @Override
     public void onCreate(Want want, LaunchParam launchParam) {
       super.onCreate(want, launchParam);
       WXEventHandler.handleWant(want); // Pass intents to WeChat handler
     }
     ```

2. **Security**:

   - Ensure all sensitive data (e.g., `partnerId`, `sign`) is securely stored and transmitted.

3. **Testing**:

   - Test with a valid WeChat sandbox account before production deployment.
