# harmony_flutter 实现短信发送



####  ohos端建立通

```
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import { AbilityAware, AbilityPluginBinding } from '@ohos/flutter_ohos';
import { UIAbility, Want } from '@kit.AbilityKit';
import sms from '@ohos.telephony.sms';

const TAG: string = "FlutterSms";
const CHANNEL_NAME = "flutter_sms";

export class Contact {
  telephone: string;

  constructor(telephone: string) {
    this.telephone = telephone;
  }
}

export class FlutterSmsPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  getUniqueClassName(): string {
    return "FlutterSmsPlugin";
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, "onAttachedToAbility");
    this.ability = binding.getAbility()
  }

  onDetachedFromAbility(): void {
    Log.i(TAG, "onDetachedFromAbility");
    this.ability = null;
  }

  private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;
  private ability: UIAbility | null = null;

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
    try {
      if (call.method == "sendSMS") {
        if (!this.canSendSMS()) {
          result.error(
            "device_not_capable",
            "The current device is not capable of sending text messages.",
            "A device may be unable to send messages if it does not support messaging or if it is not currently configured to send messages. This only applies to the ability to send text messages via iMessage, SMS, and MMS.")
          return
        }
        const message = call.argument("message") as string || ""
        const recipients = call.argument("recipients") as string || ""
        this.sendSMS(result, recipients, message)
      } else if (call.method == "canSendSMS") {
        result.success(this.canSendSMS())
      } else {
        result.notImplemented()
      }
    } catch (err) {
      result.error("Name not found", err.message, null)
    }
  }

  canSendSMS(): boolean {
    return sms.hasSmsCapability();
  }

  sendSMS(result: MethodResult, phones: string, message: string) {
    const numbers: string[] = phones.split(";")

    // 这里完善联系人和号码；姓名主要是通过手机号来查询实际联系人名称，因此这种方式还是以手机号码为主。
    let params: Array<Contact> = numbers.map(n => new Contact(n));

    let want: Want = {
      bundleName: "com.ohos.mms",
      abilityName: "com.ohos.mms.MainAbility",
      parameters: {
        contactObjects: JSON.stringify(params),
        pageFlag: "conversation",
        // 这里填写短信内容。
        content: message
      }
    };

    this.ability?.context.startAbilityForResult(want).then((data) => {
      Log.d(TAG, "Success" + JSON.stringify(data));
      result.success("SMS Sent!")
    }).catch((err: Error) => {
      Log.d(TAG, "error");
      result.error("SMS Ability Start Error", err.message, null)
    });
  }
}
```





#### flutter端代码

```
Future<String> sendSMS({
  required String message,
  required List<String> recipients,
  bool sendDirect = false,
}) =>
    FlutterSmsPlatform.instance.sendSMS(
      message: message,
      recipients: recipients,
      sendDirect: sendDirect,
    );

/// Launch SMS Url Scheme on all platforms
Future<bool> launchSms({
  String? message,
  String? number,
}) =>
    FlutterSmsPlatform.instance.launchSms(number, message);

/// Launch SMS Url Scheme on all platforms
Future<bool> launchSmsMulti({
  required String message,
  required List<String> numbers,
}) =>
    FlutterSmsPlatform.instance.launchSmsMulti(numbers, message);

/// Check if you can send SMS on this platform
Future<bool> canSendSMS() => FlutterSmsPlatform.instance.canSendSMS();

```



### flutter example 引用

```
import 'dart:async';

import 'src/flutter_sms_platform.dart';
```
