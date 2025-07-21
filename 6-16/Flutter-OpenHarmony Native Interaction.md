# Flutter-OpenHarmony Native Interaction

### MethodChannel

HarmonyOS NEXT, Huawei's latest operating system, focuses on a native HarmonyOS application ecosystem, dropping support for Android apps and shifting to its own kernel and framework. Flutter, a UI toolkit, can interact with HarmonyOS NEXT through native code, enabling developers to build cross-platform applications. This interaction is facilitated by the Platform Abstraction Layer (PAL) in a hybrid development architecture. 
HarmonyOS NEXT and Flutter Interaction:
Native HarmonyOS Apps:
HarmonyOS NEXT primarily supports native HarmonyOS applications developed using ArkTS, Huawei's language based on TypeScript. 
Flutter's Role:
Flutter can be used to create user interfaces and interact with native HarmonyOS functionalities through native code and the PAL. 
Platform Abstraction Layer (PAL):
The PAL acts as a bridge between the Flutter framework and the HarmonyOS native layer, enabling communication and data exchange. 
Hybrid Development:
Flutter and HarmonyOS NEXT can be combined in a hybrid development approach, where Flutter handles UI rendering and some logic, while native HarmonyOS code handles platform-specific tasks and performance-critical operations. 
Benefits:
This interaction allows developers to leverage Flutter's UI capabilities while utilizing HarmonyOS NEXT's performance and ecosystem. 
Key Considerations:
Native Language:
ArkTS, a superset of TypeScript, is the primary language for HarmonyOS development. 
PAL Design:
The design of the PAL is crucial for maintainability and performance in hybrid development. 
Tools:
DevEco Studio is the recommended IDE for HarmonyOS development, and it includes tools for debugging and performance analysis. 
OpenHarmony:
OpenHarmony, an open-source project based on HarmonyOS, provides a foundation for exploring and contributing to the HarmonyOS ecosystem. 
In essence, Flutter's interaction with HarmonyOS NEXT is achieved through a hybrid approach, leveraging native code and a Platform Abstraction Layer to bridge the gap between the UI framework and the underlying HarmonyOS operating system. 

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
