# Flutter与鸿蒙原生交互

### 一.MethodChannel

1.flutter端代码

- 创建MethodChannel通道
- 调用平台创建方法接收回调参数

```
//创建通道 自定义通道名字 flutter.ohos.example/test
final _platform = const MethodChannel('flutter.ohos.example/test');

//调用 平台创建的方法接收回调
final result = await _platform.invokeMethod<String>('getTestString');
```

2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建MethodChannel实例（名字需要与flutter端保持一致）
- onMethodCall回调中监听回调方法（名字需要与flutter端保持一致）
- 通过MethodResult回传参数

```
export default class TestPlugin implements FlutterPlugin {// 继承FlutterPlugin
  private channel?: MethodChannel;
  
  onAttachedToEngine(binding: FlutterPluginBinding): void {
  // 创建通道实例
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter.ohos.example/test");
    // 设置回调，调用具体的实现和传统flutter方法一致
    this.channel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        switch (call.method) {
          case "getTestString":
          	//回调数据到flutter监听层
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



