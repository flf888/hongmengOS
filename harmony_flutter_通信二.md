# Flutter与鸿蒙原生交互二

### flutter 有三种基础的通道

- **MethodChannel**：主要方式，**调用原生方法并接收返回值**，适合一次性调用。
- **EventChannel**：**事件流/数据流的持续通信**，如监听传感器数据。
- **BasicMessageChannel**：传递 **字符串或二进制信息**，适合 **双向通信**、**快速连续传递简单数据**。

### BasicMessageChannel（双向通道）

1.flutter端代码

- 创建BasicMessageChannel通道
- 调用平台创建方法接收回调参数

```
// 创建实例
final _basicChannel = const BasicMessageChannel(
      "flutter.ohos.example/base_test", StandardMessageCodec());
// 调用方法，获取平台侧的返回值
final String? reply = await _basicChannel.send('increment');
```

2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建BasicMessageChannel实例（名字需要与flutter端保持一致）
- onMessage回调中监听回调方法
- reply 回传参数

```
export default class TestPlugin implements FlutterPlugin {// 继承FlutterPlugin
  
  private basicChannel?: BasicMessageChannel<Any>;
  
  private counter = 0 ;
  
  onAttachedToEngine(binding: FlutterPluginBinding): void {
  	this.basicChannel = new BasicMessageChannel(binding.getBinaryMessenger(),"flutter.ohos.example/base_test", new StandardMessageCodec());
    this.basicChannel.setMessageHandler({
      onMessage(message: Any, reply: Reply<Any>) {
        Log.i(TAG, "收到Flutter端的信息，当前计数器值: $counter");
        // 处理来自 Flutter 的消息
             counter++
             reply.reply("计数器值: $counter")
      }
    })
  }
}
```



### EventChannel（事件监听）

1.flutter端代码

- 创建MethodChannel通道
- 调用平台创建方法接收回调参数

```
// 创建实例
final _eventChannel = const EventChannel('flutter.ohos.example/event_test');
// 监听事件回调
_eventChannel.receiveBroadcastStream().listen((event) {
	  print("EventChannel event=$event")
    });
```

2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建EventChannel实例（名字需要与flutter端保持一致）
- 设置eventSink 
- 使用eventSink 发送数据到flutter层

```
export default class TestPlugin implements FlutterPlugin {// 继承FlutterPlugin
  
  private eventChannel?: EventChannel;
  private eventSink?: EventSink;
  
  onAttachedToEngine(binding: FlutterPluginBinding): void {
  	this.eventChannel = new EventChannel(binding.getBinaryMessenger(), "flutter.ohos.example/event_test");
    this.eventChannel.setStreamHandler({
      onListen(args: Any, events: EventSink): void {
        that.eventSink = events;
      },
      onCancel(args: Any): void {
        that.eventSink = undefined;
      }
    });
  }
}
```



发送数据

```
// ...
// 使用 EventSink 发送数据后，dart断的事件监听回调会收到发送的数据。
that.eventSink?.success("eventSink message ");
```

