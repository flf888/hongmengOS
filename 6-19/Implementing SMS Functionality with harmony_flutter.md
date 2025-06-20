# Implementing SMS Functionality with harmony_flutter

## OHOS Native Implementation

	```typescript
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
	
	  // Called when attached to UIAbility
	  onAttachedToAbility(binding: AbilityPluginBinding): void {
	    Log.i(TAG, "Attached to Ability");
	    this.ability = binding.getAbility()
	  }
	
	  // Called when detached from UIAbility
	  onDetachedFromAbility(): void {
	    Log.i(TAG, "Detached from Ability");
	    this.ability = null;
	  }
	
	  private methodChannel: MethodChannel | null = null;
	  private applicationContext: Context | null = null;
	  private ability: UIAbility | null = null;
	
	  // Attach to Flutter engine
	  onAttachedToEngine(binding: FlutterPluginBinding): void {
	    this.applicationContext = binding.getApplicationContext();
	    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
	    this.methodChannel.setMethodCallHandler(this);
	  }
	
	  // Detach from Flutter engine
	  onDetachedFromEngine(binding: FlutterPluginBinding): void {
	    this.applicationContext = null;
	    this.methodChannel?.setMethodCallHandler(null);
	    this.methodChannel = null;
	  }
	
	  // Handle method calls from Flutter
	  onMethodCall(call: MethodCall, result: MethodResult): void {
	    try {
	      if (call.method == "sendSMS") {
	        // Check SMS capability
	        if (!this.canSendSMS()) {
	          result.error(
	            "device_not_capable",
	            "Current device cannot send messages",
	            "Device may lack messaging support or configuration")
	          return
	        }
	        const message = call.argument("message") as string || ""
	        const recipients = call.argument("recipients") as string || ""
	        this.sendSMS(result, recipients, message)
	      } else if (call.method == "canSendSMS") {
	        // Check SMS capability
	        result.success(this.canSendSMS())
	      } else {
	        result.notImplemented()
	      }
	    } catch (err) {
	      result.error("Method not found", err.message, null)
	    }
	  }
	
	  // Check if device can send SMS
	  canSendSMS(): boolean {
	    return sms.hasSmsCapability();
	  }
	
	  // Send SMS message
	  sendSMS(result: MethodResult, phones: string, message: string) {
	    const numbers: string[] = phones.split(";")
	
	    // Format contacts
	    let contacts: Array<Contact> = numbers.map(n => new Contact(n));
	
	    // Prepare intent for SMS app
	    let want: Want = {
	      bundleName: "com.ohos.mms",
	      abilityName: "com.ohos.mms.MainAbility",
	      parameters: {
	        contactObjects: JSON.stringify(contacts),
	        pageFlag: "conversation",
	        content: message // SMS content
	      }
	    };
	
	    // Launch SMS application
	    this.ability?.context.startAbilityForResult(want).then((data) => {
	      Log.d(TAG, "Success" + JSON.stringify(data));
	      result.success("SMS Sent!")
	    }).catch((err: Error) => {
	      Log.d(TAG, "SMS launch error");
	      result.error("SMS App Launch Error", err.message, null)
	    });
	  }
	}
	```

## Flutter API Implementation

	```dart
	/// Send SMS message through native interface
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
	
	/// Launch default SMS application with prefilled message
	Future<bool> launchSms({
	  String? message,
	  String? number,
	}) =>
	    FlutterSmsPlatform.instance.launchSms(number, message);
	
	/// Launch SMS app with multiple recipients
	Future<bool> launchSmsMulti({
	  required String message,
	  required List<String> numbers,
	}) =>
	    FlutterSmsPlatform.instance.launchSmsMulti(numbers, message);
	
	/// Check SMS capability on device
	Future<bool> canSendSMS() => FlutterSmsPlatform.instance.canSendSMS();
	```

### Flutter Example Usage

	```dart
	import 'dart:async';
	import 'src/flutter_sms_platform.dart';
	
	// Send SMS to single recipient
	await sendSMS(
	  message: "Hello from Flutter!",
	  recipients: ["+1234567890"]
	);
	
	// Launch SMS app with prefilled message
	await launchSms(
	  number: "+1234567890",
	  message: "Meeting reminder"
	);
	
	// Check SMS capability
	bool canSend = await canSendSMS();
	```

### Implementation Features:
1. **SMS Capability Check**: Verifies device supports SMS functionality
2. **Native SMS Integration**: Launches system SMS application with prefilled content
3. **Multi-Recipient Support**: Handles multiple phone numbers
4. **Error Handling**: Provides meaningful error messages for common failures
5. **Lifecycle Management**: Properly handles attachment/detachment from abilities

This implementation provides a complete solution for SMS functionality in Flutter applications running on OpenHarmony devices, leveraging the native telephony capabilities through platform channels.