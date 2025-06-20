# Implementing Phone Call Functionality with harmony_flutter

## OHOS Native Implementation

	```typescript
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
	
	let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | 
	                 bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO
	
	const TAG: string = "FlutterPhoneDirectCaller"
	
	const CHANNEL_NAME = "flutter_phone_direct_caller";
	
	export class FlutterPhoneDirectCallerPlugin implements FlutterPlugin, MethodCallHandler {
	  getUniqueClassName(): string {
	    return "FlutterPhoneDirectCallerPlugin";
	  }
	
	  private methodChannel: MethodChannel | null = null;
	  private applicationContext: Context | null = null;
	
	  // Called when plugin attaches to Flutter engine
	  onAttachedToEngine(binding: FlutterPluginBinding): void {
	    this.applicationContext = binding.getApplicationContext();
	    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
	    this.methodChannel.setMethodCallHandler(this);
	  }
	
	  // Called when plugin detaches from Flutter engine
	  onDetachedFromEngine(binding: FlutterPluginBinding): void {
	    this.applicationContext = null;
	    this.methodChannel?.setMethodCallHandler(null);
	    this.methodChannel = null;
	  }
	
	  // Handle method calls from Flutter
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
	
	  // Make phone call
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

## Flutter Dart Wrapper for Phone Calling

	```dart
	import 'dart:async';
	import 'package:flutter/services.dart';
	
	class FlutterPhoneDirectCaller {
	  static const MethodChannel _channel =
	      MethodChannel('flutter_phone_direct_caller');
	
	  /// Initiates phone call to specified number
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

### Implementation Workflow:
1. **Flutter Invocation**:  
   Call `FlutterPhoneDirectCaller.callNumber("+1234567890")` from Dart code

2. **Platform Channel**:  
   Method channel `flutter_phone_direct_caller` bridges Dart to native

3. **Native Execution**:  
   OHOS `call.makeCall()` initiates phone call through system telephony services

4. **Result Handling**:  
   Returns `true` on success, `false` on failure

This implementation provides a complete solution for initiating phone calls from Flutter applications running on OpenHarmony devices.