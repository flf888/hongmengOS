# Implementing Screen Brightness Control with harmony_flutter

## OHOS Native Implementation

	```typescript
	import settings from '@ohos.settings';
	import window from '@ohos.window';
	import FlutterManager from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterManager';
	import { AbilityPluginBinding, FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/index';
	import MethodChannel, {
	  MethodCallHandler,
	  MethodResult
	} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
	import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
	import Log from '@ohos/flutter_ohos/src/main/ets/util/Log';
	
	const TAG = "FlutterScreenPlugin"
	
	export class FlutterScreenPlugin implements FlutterPlugin, MethodCallHandler {
	  private channelName: string = "github.com/clovisnicolas/flutter_screen"
	  private abilityPluginBinding: AbilityPluginBinding | null = null;
	  private channel: MethodChannel | null = null
	  private mainWindow: window.Window | null = null;
	
	  getUniqueClassName(): string {
	    return TAG;
	  }
	
	  // Called when attached to Flutter engine
	  onAttachedToEngine(binding: FlutterPluginBinding): void {
	    this.channel = new MethodChannel(binding.getBinaryMessenger(), this.channelName)
	    this.channel?.setMethodCallHandler(this)
	  }
	
	  // Called when detached from Flutter engine
	  onDetachedFromEngine(binding: FlutterPluginBinding): void {
	    this.channel?.setMethodCallHandler(null)
	    this.channel = null
	  }
	
	  // Called when attached to UIAbility
	  onAttachedToAbility(binding: AbilityPluginBinding): void {
	    this.abilityPluginBinding = binding;
	  }
	
	  // Called when detached from UIAbility
	  onDetachedFromAbility(): void {
	    this.abilityPluginBinding = null;
	    this.mainWindow = null
	  }
	
	  // Get the main window reference
	  getWindow(): void {
	    this.mainWindow = FlutterManager.getInstance()
	      .getWindowStage(FlutterManager.getInstance().getUIAbility(this.abilityPluginBinding?.getAbility().context))
	      .getMainWindowSync();
	  }
	
	  // Handle method calls from Flutter
	  onMethodCall(call: MethodCall, result: MethodResult): void {
	    try {
	      if (!this.mainWindow) {
	        this.getWindow(); // Initialize window if not set
	      }
	      switch (call.method) {
	        case "brightness":
	          // Get current brightness
	          result.success(this.getBrightness());
	          break;
	        case "setBrightness":
	          // Set new brightness
	          this.mainWindow?.setWindowBrightness(parseFloat(call.argument("brightness")));
	          result.success(null);
	          break;
	        case "isKeptOn":
	          // Check if screen is kept on
	          let flags: boolean = this.mainWindow?.getWindowProperties().isKeepScreenOn || false
	          result.success(flags);
	          break;
	        case "keepOn":
	          // Set screen keep-on state
	          let on: boolean = call.argument("on");
	          if (on) {
	            Log.i(TAG, "Keeping screen on ");
	            this.mainWindow?.setWindowKeepScreenOn(true);
	          } else {
	            Log.i(TAG, "Not keeping screen on");
	            this.mainWindow?.setWindowKeepScreenOn(false);
	          }
	          result.success(null);
	          break;
	
	        default:
	          result.notImplemented();
	          break;
	      }
	    } catch (e) {
	      Log.e(TAG, "Screen brightness operation failed");
	    }
	  }
	
	  // Retrieve current brightness value
	  getBrightness(): number {
	    const brightness = this.mainWindow?.getWindowProperties().brightness;
	    if (brightness && brightness >= 0) {
	      return brightness
	    }
	    // Fallback to system brightness if window brightness not available
	    let result: number;
	    try {
	      // Get system brightness setting
	      let value = settings.getValueSync(
	        this.abilityPluginBinding?.getAbility().context,
	        settings.display.SCREEN_BRIGHTNESS_STATUS,
	        '100',
	        settings.domainName.DEVICE_SHARED
	      )
	      result = parseFloat(value) / 255; // Normalize to 0-1 range
	    } catch (err) {
	      result = 1.0; // Default to maximum brightness
	      Log.e(TAG, "Failed to get system brightness");
	    }
	    return result;
	  }
	}
	```

## Flutter API Implementation

	```dart
	import 'dart:async';
	import 'package:flutter/services.dart';
	
	class Screen {
	  static const MethodChannel _channel = 
	      const MethodChannel('github.com/clovisnicolas/flutter_screen');
	
	  /// Get current screen brightness (0.0 to 1.0)
	  static Future<double> get brightness async => 
	      (await _channel.invokeMethod('brightness')) as double;
	  
	  /// Set screen brightness (0.0 to 1.0)
	  static Future setBrightness(double brightness) =>
	      _channel.invokeMethod('setBrightness', {"brightness": brightness});
	  
	  /// Check if screen is kept on
	  static Future<bool> get isKeptOn async => 
	      (await _channel.invokeMethod('isKeptOn')) as bool;
	  
	  /// Enable/disable screen keep-on
	  static Future keepOn(bool on) => 
	      _channel.invokeMethod('keepOn', {"on": on});
	}
```

## Example Flutter Implementation

	```dart
	class _MyAppState extends State<MyApp> {
	  bool _isKeptOn = false;
	  double _brightness = 1.0;
	
	  @override
	  initState() {
	    super.initState();
	    initPlatformState(); // Initialize screen state
	  }
	
	  // Retrieve initial screen settings
	  initPlatformState() async {
	    bool keptOn = await Screen.isKeptOn;
	    double brightness = await Screen.brightness;
	    setState(() {
	      _isKeptOn = keptOn;
	      _brightness = brightness;
	    });
	  }
	
	  @override
	  Widget build(BuildContext context) {
	    return MaterialApp(
	      home: Scaffold(
	        appBar: AppBar(title: Text('Screen Brightness Control')),
	        body: Center(
	          child: Column(
	            children: [
	              // Screen keep-on toggle
	              Row(
	                mainAxisAlignment: MainAxisAlignment.center,
	                children: [
	                  Text("Keep Screen On? "),
	                  Checkbox(
	                    value: _isKeptOn,
	                    onChanged: (bool b) {
	                      Screen.keepOn(b);
	                      setState(() { _isKeptOn = b; });
	                    }
	                  )
	                ]
	              ),
	              // Brightness slider
	              Text("Brightness:"),
	              Slider(
	                value: _brightness,
	                onChanged: (double b) {
	                  setState(() { _brightness = b; });
	                  Screen.setBrightness(b);
	                }
	              )
	            ]
	          )
	        ),
	      ),
	    );
	  }
	}
	```

### Flutter Usage

	```dart
	import 'package:flutter/material.dart';
	import 'package:screen/screen.dart'; // Import screen control package
	
	void main() => runApp(MyApp());
	
	class MyApp extends StatelessWidget {
	  @override
	  Widget build(BuildContext context) {
	    return MaterialApp(
	      home: BrightnessControlScreen(),
	    );
	  }
	}
	```

### Key Features:
1. **Brightness Control**: Get and set screen brightness (0.0-1.0 range)
2. **Keep-Screen-On**: Toggle screen sleep prevention
3. **Platform Integration**: Seamlessly bridges Flutter to OHOS window management
4. **Error Handling**: Graceful fallback to system settings when needed
5. **Reactive UI**: Synchronizes native settings with Flutter widget state

This implementation provides a complete solution for managing screen brightness and keep-on settings in Flutter applications running on OpenHarmony devices.