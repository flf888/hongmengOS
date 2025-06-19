# Flutter-OpenHarmony Native Interaction

### MethodChannel

1. Flutter Side Code

- Create MethodChannel instance
- Call platform method and receive callback result

```
// Create channel with custom name: flutter.ohos.example/test
final _platform = const MethodChannel('flutter.ohos.example/test');

// Call platform method and receive result
final result = await _platform.invokeMethod<String>('getTestString');
```

1. OpenHarmony Side Code

- Implement FlutterPlugin's onAttachedToEngine method
- Create matching MethodChannel instance
- Handle method calls in onMethodCall callback
- Return result using MethodResult

```
export default class TestPlugin implements FlutterPlugin {
  private channel?: MethodChannel;
  
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    // Create channel instance
    this.channel = new MethodChannel(
      binding.getBinaryMessenger(), 
      "flutter.ohos.example/test"
    );
    
    // Set method call handler
    this.channel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        switch (call.method) {
          case "getTestString":
            // Return result to Flutter
            result.success("test string");
            break;
          default:
            result.notImplemented();
            break;
        }
      }
    })
  }
}
```

