# harmony_flutter_keyboard_visibility(监听动态键盘) 

### 一.MethodChannel

1.flutter端代码

- 创建StreamBuilder监听event
- 接收ohos端传递过来的状态值

```
   final KeyboardVisibilityController? controller;

  KeyboardVisibilityController get _controller =>
      controller ?? KeyboardVisibilityController();

  const KeyboardVisibilityBuilder({
    Key? key,
    required this.builder,
    this.controller,
  }) : super(key: key);

  /// A builder method that exposes if the native keyboard is visible.
  final Widget Function(BuildContext, bool isKeyboardVisible) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _controller.onChange,
      initialData: _controller.isVisible,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return builder(context, snapshot.data!);
        } else {
          return builder(context, false);
        }
      },
    );
  }
```

```
  监听数据回传
  
  static final _onChangeController = StreamController<bool>();
  static final _onChange = _onChangeController.stream.asBroadcastStream();
  
  static Stream<bool> get onChange {
    // If _testIsVisible set, don't try to create the EventChannel
    if (!_isInitialized && _testIsVisible == null) {
      _platform.onChange.listen(_updateValue);
      _isInitialized = true;
    }
    return _onChange;
  }
```

2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建MethodChannel实例flutter_keyboard_visibility
- setStreamHandler,eventSink
- 通过eventSink回传参数

```
export default class FlutterKeyboardVisibilityPlugin implements FlutterPlugin, StreamHandler, AbilityAware {
  private eventSink: EventSink | null = null;
  private isVisible: boolean = false;
  private context: common.Context | null = null;
  private window: window.Window | undefined = undefined;

  constructor() {

  }

  getUniqueClassName(): string {
    return "FlutterKeyboardVisibilityPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.init(binding.getBinaryMessenger());
    this.context = binding.getApplicationContext();

  }

  private init(messenger: BinaryMessenger): void {
    const eventChannel = new EventChannel(messenger, "flutter_keyboard_visibility");
    eventChannel.setStreamHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
  }

  onDetachedFromAbility(): void {
    this.unregisterListener();
  }

  onListen(o: ESObject, eventSink: EventSink): void {
    this.eventSink = eventSink;
    this.listenForKeyboard();
  }

  onCancel(o: ESObject): void {
    this.eventSink = null;
  }

  private async listenForKeyboard(): Promise<void> {
    try {
      if(this.window == undefined) {
        const uiAbility = FlutterManager.getInstance().getUIAbility((getContext(this)));
        const windowStage = FlutterManager.getInstance().getWindowStage(uiAbility);
        this.window = windowStage.getMainWindowSync();
      }
      this.window?.on("avoidAreaChange", (data) => {
        if (data.type == 3) {
          let newState = data.area.bottomRect.height > 0 ? true : false;
          if (newState != this.isVisible) {
            this.isVisible = newState;
            if (this.eventSink != null) {
              this.eventSink.success(this.isVisible ? 1 : 0);
            }
          }
        }
      });

    } catch (err) {
      Log.e(TAG, "Failed to obtain the top window. Cause: " + JSON.stringify(err));
    }

  }

  private unregisterListener(): void {
    if(this.window != undefined) {
      this.window.off("avoidAreaChange", (data) => {
        this.window = undefined;
      });
    }
  }
}
```



