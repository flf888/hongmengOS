# Obtaining UDID with harmony_flutter

**UDID Considerations**:  
- UDID (Unique Device Identifier) may change after factory reset  
- Can also change after OTA updates to Android 8.0+  
- Rooted/jailbroken devices may have mutable IDs  
- Extremely difficult to guess existing user IDs  

## OHOS Implementation for UDID Retrieval

	```typescript
	import identifier from '@ohos.identifier.oaid'; // OAID library
	
	export default class FlutterUdidPlugin implements MethodCallHandler, FlutterPlugin {
	  private channel: MethodChannel | null = null
	  private applicationContext: common.Context | null = null
	  private ability: UIAbility | null = null;
	
	  constructor(context?: common.Context) {
	    if (context) {
	      this.applicationContext = context;
	    }
	  }
	
	  getUniqueClassName(): string {
	    return "FlutterUdidPlugin";
	  }
	
	  // Attach to Flutter engine
	  onAttachedToEngine(binding: FlutterPluginBinding): void {
	    this.applicationContext = binding.getApplicationContext();
	    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_udid")
	    this.channel.setMethodCallHandler(this)
	  }
	
	  // Handle ability attachment
	  onAttachedToAbility(binding: AbilityPluginBinding): void {
	    this.ability = binding.getAbility()
	  }
	
	  // Handle ability detachment
	  onDetachedFromAbility(): void {
	    this.ability = null;
	  }
	
	  // Process method calls from Flutter
	  onMethodCall(call: MethodCall, result: MethodResult): void {
	    if (call.method == "getUDID") {
	      this.requestPermissions().then((data: boolean) => {
	        this.getUDID().then((udid: string | null) => {
	          if (!udid) {
	            result.error("UNAVAILABLE", "UDID not available", null)
	          } else {
	            // Send UDID to Flutter layer
	            result.success(udid)
	          }
	        })
	      })
	    } else {
	      result.notImplemented()
	    }
	  }
	
	  // Clean up on engine detachment
	  onDetachedFromEngine(binding: FlutterPluginBinding): void {
	    this.channel?.setMethodCallHandler(null)
	  }
	
	  // Retrieve OAID from HarmonyOS
	  private async getUDID(): Promise<string | null> {
	    try {
	      return await identifier.getOAID() // Official OAID API
	    } catch (err) {
	      return null
	    }
	  }
	
	  // Request necessary permissions
	  private async requestPermissions(): Promise<boolean> {
	    if (!this.ability) {
	      Log.i(TAG, "Permission request requires attached ability");
	      return false
	    }
	    try {
	      const results = await requestPermissions(this.ability!.context)
	      return results || false
	    } catch (e) {
	      return false
	    }
	  }
	}
	```

## Flutter Implementation for UDID Access

	```dart
	class FlutterUdid {
	  // Create method channel
	  static const MethodChannel _channel = 
	      const MethodChannel('flutter_udid');
	
	  /// Gets platform-specific UDID format:
	  /// - iOS: 7946DA4E-8429-423C-B405-B3FC77914E3E
	  /// - Android/HarmonyOS: 8af8770a27cfd182
	  static Future<String> get udid async {
	    final String udid = await _channel.invokeMethod('getUDID');
	    return udid;
	  }
	
	  /// Gets consistent UDID format across platforms:
	  /// Example: 984725b6c4f55963cc52fca0f943f9a8060b1c71900d542c79669b6dc718a64b
	  static Future<String> get consistentUdid async {
	    final String udid = await _channel.invokeMethod('getUDID');
	    var bytes = utf8.encode(udid);
	    var digest = sha256.convert(bytes); // SHA-256 hashing
	    return digest.toString();
	  }
	}
	```

## Flutter Usage Example

	```dart
	import 'package:flutter_udid/flutter_udid.dart';
	
	// Get raw device ID
	String deviceId = await FlutterUdid.udid;
	
	// Get consistent hashed ID
	String hashedId = await FlutterUdid.consistentUdid;
	
	print("Device ID: $deviceId");
	print("Hashed ID: $hashedId");
	```

### Key Features:
1. **Platform-Specific Retrieval**:
   - Uses HarmonyOS official `@ohos.identifier.oaid` package
   - Handles Android compatibility through OAID standard

2. **Permission Management**:
   - Automatically requests required permissions
   - Gracefully handles permission denials

3. **Consistent Identification**:
   - Provides raw device-specific UDID
   - Offers SHA-256 hashed version for consistent format
   - Maintains user privacy through hashing

4. **Error Handling**:
   - Returns "UNAVAILABLE" error when ID inaccessible
   - Null checks for empty responses
   - Exception catching at all levels

This implementation provides a reliable solution for obtaining device identifiers in Flutter applications running on HarmonyOS, balancing accessibility with privacy considerations.