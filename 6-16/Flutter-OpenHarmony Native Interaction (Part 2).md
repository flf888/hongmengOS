# Flutter-OpenHarmony Native Interaction (Part 2)

### Flutter's Three Fundamental Channels

- **MethodChannel**: Primary method for **calling native methods and receiving return values**, suitable for one-time calls.
- **EventChannel**: For **continuous communication via event/data streams**, e.g., monitoring sensor data.
- **BasicMessageChannel**: Transmits **strings or binary information**, ideal for **bidirectional communication** and **rapid transfer of simple data**.

### BasicMessageChannel (Bidirectional Channel)

1. Flutter Side Code

- Create BasicMessageChannel instance
- Send messages to platform and receive responses

```
// Create instance
final _basicChannel = const BasicMessageChannel(
      "flutter.ohos.example/base_test", StandardMessageCodec());
      
// Call method and receive response from platform
final String? reply = await _basicChannel.send('increment');
```

1. OpenHarmony Side Code

- Implement FlutterPlugin's onAttachedToEngine method
- Create matching BasicMessageChannel instance
- Handle messages in onMessage callback
- Reply with response data

```
export default class TestPlugin implements FlutterPlugin {
  
  private basicChannel?: BasicMessageChannel<Any>;
  private counter = 0;
  
  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.basicChannel = new BasicMessageChannel(
      binding.getBinaryMessenger(),
      "flutter.ohos.example/base_test", 
      new StandardMessageCodec()
    );
    
    this.basicChannel.setMessageHandler({
      onMessage(message: Any, reply: Reply<Any>) {
        Log.i(TAG, "Received message from Flutter. Current counter: $counter");
        // Process message from Flutter
        counter++;
        reply.reply("Counter value: $counter");
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

```
// ...
// Using eventSink sends data to Flutter's event listener
that.eventSink?.success("Event message from OHOS");
```
