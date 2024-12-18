# harmony_flutter 实现拨打电话功能

####  ohos端建立通

```
import call from '@ohos.telephony.call';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
import deviceInfo from '@ohos.deviceInfo';

import bundleManager from '@ohos.bundle.bundleManager'

let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO

const TAG: string = "FlutterPhoneDirectCaller"

const CHANNEL_NAME = "flutter_phone_direct_caller";

export class FlutterPhoneDirectCallerPlugin implements FlutterPlugin, MethodCallHandler {
  getUniqueClassName(): string {
    return "FlutterPhoneDirectCallerPlugin";
  }

  private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;

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
      if (call.method == "callNumber") {
        const number: string = call.argument("number")
        Log.i(TAG, deviceInfo.osFullName)
        this.callNumber(number).then((isSuccess) => {
          result.success(isSuccess);
        });
      } else {
        result.notImplemented()
      }
    } catch (err) {
      result.error("Name not found", err.message, null)
    }
  }

  async callNumber(number: string) {
    try {
      await call.makeCall(number)
      return true;
    } catch (e) {
      return false;
    }
  }
}
```



#### flutter端代码拨打电话类代码封装

```
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterPhoneDirectCaller {
  static const MethodChannel _channel =
      MethodChannel('flutter_phone_direct_caller');

  static Future<bool?> callNumber(String number) async {
    return await _channel.invokeMethod(
      'callNumber',
      <String, Object>{
        'number': number,
      },
    );
  }
}
```

这样就能通过调用FlutterPhoneDirectCaller的callNumber方法来实现拨打电话的功能了.