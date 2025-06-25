# Screen Orientation Management for harmony_flutter

## Flutter Implementation

### Method Channel Setup  
	```dart
	class OrientationPlugin {
	  // Create method channel for orientation control
	  static const _methodChannel =
	      const MethodChannel('sososdk.github.com/orientation');
	  
	  // Create event channel for orientation changes
	  static const _eventChannel =
	      const EventChannel('sososdk.github.com/orientationEvent');
	
	  /// Set enabled system UI overlays
	  static Future<void> setEnabledSystemUIOverlays(
	      List<SystemUiOverlay> overlays) async {
	    if (Platform.isAndroid) {
	      await _methodChannel.invokeMethod<void>(
	        'SystemChrome.setEnabledSystemUIOverlays',
	        _stringify(overlays),
	      );
	    } else {
	      SystemChrome.setEnabledSystemUIOverlays(overlays);
	    }
	  }
	
	  /// Set preferred device orientations
	  static Future<void> setPreferredOrientations(
	      List<DeviceOrientation> orientations) async {
	    await _methodChannel.invokeMethod<void>(
	      'SystemChrome.setPreferredOrientations',
	      _stringify(orientations),
	    );
	  }
	
	  /// Force specific orientation
	  static Future<void> forceOrientation(DeviceOrientation orientation) async {
	    await _methodChannel.invokeMethod<void>(
	      'SystemChrome.forceOrientation',
	      orientation.toString(),
	    );
	  }
	
	  // Convert orientation list to string list
	  static List<String> _stringify(List<dynamic> list) {
	    final List<String> result = <String>[];
	    for (dynamic item in list) result.add(item.toString());
	    return result;
	  }
	
	  // Orientation change stream
	  static Stream<DeviceOrientation>? _onOrientationChange;
	
	  /// Get orientation change events
	  static Stream<DeviceOrientation> get onOrientationChange {
	    if (_onOrientationChange == null) {
	      _onOrientationChange = _eventChannel
	          .receiveBroadcastStream()
	          .map((event) => _convert(event));
	    }
	    return _onOrientationChange!;
	  }
	
	  // Convert string to DeviceOrientation enum
	  static DeviceOrientation _convert(String value) {
	    if (value == DeviceOrientation.portraitUp.toString()) {
	      return DeviceOrientation.portraitUp;
	    } else if (value == DeviceOrientation.portraitDown.toString()) {
	      return DeviceOrientation.portraitDown;
	    } else if (value == DeviceOrientation.landscapeLeft.toString()) {
	      return DeviceOrientation.landscapeLeft;
	    } else if (value == DeviceOrientation.landscapeRight.toString()) {
	      return DeviceOrientation.landscapeRight;
	    } else {
	      throw FlutterError('Unknown orientation');
	    }
	  }
	}
	```

## HarmonyOS Implementation

	```typescript
	export default class OrientationPlugin implements FlutterPlugin, StreamHandler, AbilityAware {
	  getUniqueClassName(): string {
	    return "OrientationPlugin";
	  }
	
	  // Called when attached to UIAbility
	  onAttachedToAbility(binding: AbilityPluginBinding): void {
	    Log.i(TAG, "Attached to Ability");
	    this.ability = binding.getAbility();
	  }
	
	  // Called when detached from UIAbility
	  onDetachedFromAbility(): void {
	    Log.i(TAG, "Detached from Ability");
	    this.ability = null;
	  }
	
	  // Convert window orientation to DeviceOrientation string
	  orientation(orientation: number) {
	    if (orientation == window.Orientation.PORTRAIT) {
	      return "DeviceOrientation.portraitUp";
	    } else if (orientation == window.Orientation.PORTRAIT_INVERTED) {
	      return "DeviceOrientation.portraitDown";
	    } else if (orientation == window.Orientation.LANDSCAPE) {
	      return "DeviceOrientation.landscapeLeft";
	    } else if (orientation == window.Orientation.LANDSCAPE_INVERTED) {
	      return "DeviceOrientation.landscapeRight";
	    } else {
	      return null;
	    }
	  }
	
	  // Called when attached to Flutter engine
	  onAttachedToEngine(binding: FlutterPluginBinding): void {
	    this.applicationContext = binding.getApplicationContext();
	    
	    // Method channel for orientation control
	    this.methodChannel = new MethodChannel(
	      binding.getBinaryMessenger(), 
	      "sososdk.github.com/orientation"
	    );
	    this.methodChannel.setMethodCallHandler(this);
	
	    // Event channel for orientation monitoring
	    this.eventChannel = new EventChannel(
	      binding.getBinaryMessenger(), 
	      "sososdk.github.com/orientationEvent"
	    );
	    
	    // Set up orientation change monitoring
	    this.eventChannel.setStreamHandler({
	      onListen: (args: Object, eventSink: EventSink) => {
	        // Use accelerometer to detect device rotation
	        sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
	          let angle = 0;
	          let magnitude = data.x * data.x + data.y * data.y;
	          
	          // Calculate rotation angle
	          if (magnitude * 4 >= data.z * data.z) {
	            let OneEightyOverPi = 57.29577957855;
	            angle = 90 - Math.round(Math.atan2(-data.y, data.x) * OneEightyOverPi);
	            // Normalize angle to 0-359 range
	            while (angle >= 360) angle -= 360;
	            while (angle < 0) angle += 360;
	          }
	
	          // Send orientation change
	          this.sendOrientationChange(eventSink, this.convertAngle(angle))
	        }, { interval: 100000000 }); // 100ms interval
	      },
	      onCancel: () => {
	        sensor.off(sensor.SensorId.ACCELEROMETER); // Stop monitoring
	      }
	    });
	  }
	
	  private prevOrientation: number | null = null;
	
	  // Send orientation change notification
	  sendOrientationChange(eventSink: EventSink, orientation: number) {
	    if (this.prevOrientation !== orientation) {
	      this.prevOrientation = orientation;
	      const value = this.orientation(orientation);
	      if (value !== null) {
	        eventSink.success(value); // Notify Flutter
	      }
	    }
	  }
	
	  // Called when detached from Flutter engine
	  onDetachedFromEngine(binding: FlutterPluginBinding): void {
	    // Clean up resources
	    this.methodChannel?.setMethodCallHandler(null);
	    this.methodChannel = null;
	    this.eventChannel?.setStreamHandler(null);
	    this.eventChannel = null;
	  }
	
	  // Handle method calls from Flutter
	  onMethodCall(call: MethodCall, result: MethodResult): void {
	    try {
	      if (call.method == "SystemChrome.setEnabledSystemUIOverlays") {
	        // Implemented in Dart
	        result.notImplemented();
	      } else if (call.method == "SystemChrome.setPreferredOrientations") {
	        // Set preferred orientations
	        this.setSystemChromePreferredOrientations(call.args);
	        result.success(null);
	      } else if (call.method == "SystemChrome.forceOrientation") {
	        // Force specific orientation
	        this.forceOrientation(call.args);
	        result.success(null);
	      } else {
	        result.notImplemented()
	      }
	    } catch (err) {
	      result.error("Method not found", err.message, null)
	    }
	  }
	
	  // Set preferred orientations from Flutter
	  setSystemChromePreferredOrientations(orientations: string[]) {
	    let requestedOrientation = 0x00;
	    // Map orientations to bitmask
	    for (let index = 0; index < orientations.length; index += 1) {
	      if (orientations[index] === "DeviceOrientation.portraitUp") {
	        requestedOrientation |= 0x01;
	      } else if (orientations[index] === "DeviceOrientation.landscapeLeft") {
	        requestedOrientation |= 0x02;
	      } else if (orientations[index] === "DeviceOrientation.portraitDown") {
	        requestedOrientation |= 0x04;
	      } else if (orientations[index] === "DeviceOrientation.landscapeRight") {
	        requestedOrientation |= 0x08;
	      }
	    }
	    
	    // Apply orientation settings
	    window.getLastWindow(this.ability?.context).then(windowClass => {
	      switch (requestedOrientation) {
	        case 0x00: // Unspecified
	          windowClass.setPreferredOrientation(window.Orientation.UNSPECIFIED);
	          break;
	        case 0x01: // Portrait
	          windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
	          break;
	        case 0x02: // Landscape
	          windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
	          break;
	        // ... other orientation combinations
	        default: // Auto-rotation for complex combinations
	          windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
	          break;
	      }
	    });
	  }
	
	  // Force specific orientation
	  forceOrientation(orientation: string) {
	    window.getLastWindow(this.ability?.context).then(windowClass => {
	      if (orientation === "DeviceOrientation.portraitUp") {
	        windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
	      } else if (orientation === "DeviceOrientation.portraitDown") {
	        windowClass.setPreferredOrientation(window.Orientation.PORTRAIT_INVERTED);
	      } else if (orientation === "DeviceOrientation.landscapeLeft") {
	        windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE_INVERTED);
	      } else if (orientation === "DeviceOrientation.landscapeRight") {
	        windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
	      } else {
	        windowClass.setPreferredOrientation(window.Orientation.UNSPECIFIED);
	      }
	    })
	  }
	
	  // Convert accelerometer angle to orientation
	  convertAngle(angle: number) {
	    angle = angle % 360;
	    if (angle >= 120 && angle <= 240) {
	      return window.Orientation.PORTRAIT;
	    } else if (angle >= 30 && angle <= 150) {
	      return window.Orientation.LANDSCAPE_INVERTED;
	    } else if (angle >= 300 || (angle <= 60 && angle > 0)) {
	      return window.Orientation.PORTRAIT_INVERTED;
	    } else if (angle >= 210 && angle <= 330) {
	      return window.Orientation.LANDSCAPE;
	    } else {
	      return window.Orientation.UNSPECIFIED;
	    }
	  }
	}
	```

## Key Features

1. **Comprehensive Orientation Control**:
   - Set preferred orientations
   - Force specific orientation
   - Detect orientation changes in real-time

2. **Cross-Platform Compatibility**:
   - Uses standard Flutter orientation enums
   - Maps HarmonyOS orientations to Flutter equivalents
   - Handles Android-specific implementations separately

3. **Efficient Monitoring**:
   - Uses accelerometer data with 100ms sampling
   - Calculates precise rotation angle
   - Only notifies on actual orientation changes

4. **Lifecycle Management**:
   - Properly attaches/detaches from abilities
   - Cleans up resources when no longer needed
   - Handles event channel cancellation

This implementation provides a complete solution for managing screen orientation in Flutter applications running on HarmonyOS devices, enabling both reactive monitoring and proactive control of device orientation.