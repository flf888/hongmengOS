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
### EventChannel (Event Monitoring)

1. Flutter Side Code

- Create EventChannel instance
- Listen for event broadcasts

```
// Create instance
final _eventChannel = const EventChannel('flutter.ohos.example/event_test');
  
// Listen for event callbacks
_eventChannel.receiveBroadcastStream().listen((event) {
    print("EventChannel event: $event")
});
```

1. OpenHarmony Side Code

- Implement FlutterPlugin's onAttachedToEngine method
- Create matching EventChannel instance
- Set up eventSink for data streaming
- Use eventSink to send data to Flutter

```
export default class TestPlugin implements FlutterPlugin {
  
  private eventChannel?: EventChannel;
  private eventSink?: EventSink;
  
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.eventChannel = new EventChannel(
      binding.getBinaryMessenger(), 
      "flutter.ohos.example/event_test"
    );
    
    this.eventChannel.setStreamHandler({
      onListen(args: Any, events: EventSink): void {
        that.eventSink = events;  // Store event sink
      },
      onCancel(args: Any): void {
        that.eventSink = undefined;  // Clear reference
      }
    });
  }
}
```

Sending Data to Flutter
