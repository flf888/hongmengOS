# harmony_flutter_orientation(屏幕旋转)

#### flutter端监听鸿蒙手机得屏幕横竖屏切换等各种状态

### 一.MethodChannel

1.flutter端代码

- 创建MethodChannel交互通道
- 接收ohos端传递过来状态

```
 class OrientationPlugin {
  static const _methodChannel =
      const MethodChannel('sososdk.github.com/orientation');

  static const _eventChannel =
      const EventChannel('sososdk.github.com/orientationEvent');

  /// see [SystemChrome.setEnabledSystemUIOverlays]
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

  /// see [SystemChrome.setPreferredOrientations]
  static Future<void> setPreferredOrientations(
      List<DeviceOrientation> orientations) async {
    await _methodChannel.invokeMethod<void>(
      'SystemChrome.setPreferredOrientations',
      _stringify(orientations),
    );
  }

  /// Force change of orientation
  static Future<void> forceOrientation(DeviceOrientation orientation) async {
    await _methodChannel.invokeMethod<void>(
      'SystemChrome.forceOrientation',
      orientation.toString(),
    );
  }

  static List<String> _stringify(List<dynamic> list) {
    final List<String> result = <String>[];
    for (dynamic item in list) result.add(item.toString());
    return result;
  }

  static Stream<DeviceOrientation>? _onOrientationChange;

  static Stream<DeviceOrientation> get onOrientationChange {
    if (_onOrientationChange == null) {
      _onOrientationChange = _eventChannel
          .receiveBroadcastStream()
          .map((event) => _convert(event));
    }
    return _onOrientationChange!;
  }

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
      throw FlutterError('Unknow orientation');
    }
  }
}
```

2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建MethodChannel实例video_compress
- onMethodCall回调中监听回调方法（名字需要与flutter端保持一致）
- 通过MethodResult回传参数

```
getUniqueClassName(): string {
    return "OrientationPlugin";
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    Log.i(TAG, "onAttachedToAbility");
    this.ability = binding.getAbility()
  }

  onDetachedFromAbility(): void {
    Log.i(TAG, "onDetachedFromAbility");
    this.ability = null;
  }

  private methodChannel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;
  private applicationContext: Context | null = null;
  private ability: UIAbility | null = null;
  private isLayoutFullScreen = false;

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

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), "sososdk.github.com/orientation");
    this.methodChannel.setMethodCallHandler(this);

    // 监听屏幕旋转
    this.eventChannel = new EventChannel(binding.getBinaryMessenger(), "sososdk.github.com/orientationEvent");
    this.eventChannel.setStreamHandler({
      onListen: (args: Object, eventSink: EventSink) => {

        sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
          // Log.i(TAG, `xyz ${data.x} ${data.y} ${data.z}`)
          let angle = 0;
          let magnitude = data.x * data.x + data.y * data.y;
          // Don't trust the angle if the magnitude is small compared to the y value
          if (magnitude * 4 >= data.z * data.z) {
            let OneEightyOverPi = 57.29577957855;
            angle = 90 - Math.round(Math.atan2(-data.y, data.x) * OneEightyOverPi);
            // normalize to 0 - 359 range
            while (angle >= 360) {
              angle -= 360;
            }
            while (angle < 0) {
              angle += 360;
            }
          }

          this.sendOrientationChange(eventSink, this.convertAngle(angle))
        }, { interval: 100000000 });

      },
      onCancel: () => {
        sensor.off(sensor.SensorId.ACCELEROMETER);
      }
    });
  }

  private prevOrientation: number | null = null

  sendOrientationChange(eventSink: EventSink, orientation: number) {
    if (this.prevOrientation !== orientation) {
      this.prevOrientation = orientation;
      const value = this.orientation(orientation);
      if (value !== null) {
        eventSink.success(value);
      }
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
    this.eventChannel?.setStreamHandler(null);
    this.eventChannel = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    try {
      if (call.method == "SystemChrome.setEnabledSystemUIOverlays") {
        // this.setSystemChromeEnabledSystemUIOverlays()
        // result.success(null);
        // 利用dart实现，无需native实现
        result.notImplemented();
      } else if (call.method == "SystemChrome.setPreferredOrientations") {
        this.setSystemChromePreferredOrientations(call.args);
        result.success(null);
      } else if (call.method == "SystemChrome.forceOrientation") {
        this.forceOrientation(call.args);
        result.success(null);
      } else {
        result.notImplemented()
      }
    } catch (err) {
      result.error("Name not found", err.message, null)
    }
  }

  // setSystemChromeEnabledSystemUIOverlays() {
  //   window.getLastWindow(this.ability?.context).then(windowClass => {
  //     this.isLayoutFullScreen = !this.isLayoutFullScreen;
  //     windowClass.setWindowLayoutFullScreen(this.isLayoutFullScreen, (err: BusinessError) => {
  //       const errCode: number = err.code;
  //       if (errCode) {
  //         console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
  //         return;
  //       }
  //       console.info('Succeeded in setting the window layout to full-screen mode.');
  //     });
  //   })
  // }

  setSystemChromePreferredOrientations(orientations: string[]) {
    let requestedOrientation = 0x00;
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
    window.getLastWindow(this.ability?.context).then(windowClass => {
      switch (requestedOrientation) {
        case 0x00:
          windowClass.setPreferredOrientation(window.Orientation.UNSPECIFIED);
          break;
        case 0x01:
          windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
          break;
        case 0x02:
          windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
          break;
        case 0x04:
          windowClass.setPreferredOrientation(window.Orientation.PORTRAIT_INVERTED);
          break;
        case 0x05:
          windowClass.setPreferredOrientation(window.Orientation.PORTRAIT);
          break;
        case 0x08:
          windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE_INVERTED);
          break;
        case 0x0a:
          windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE);
          break;
        case 0x0b:
          windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
          break;
        case 0x0f:
          windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
          break;
        case 0x03: // portraitUp and landscapeLeft
        case 0x06: // portraitDown and landscapeLeft
        case 0x07: // portraitUp, portraitDown, and landscapeLeft
        case 0x09: // portraitUp and landscapeRight
        case 0x0c: // portraitDown and landscapeRight
        case 0x0d: // portraitUp, portraitDown, and landscapeRight
        case 0x0e: // portraitDown, landscapeLeft, and landscapeRight
          windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
          break;
      }
    });
  }

  forceOrientation(orientation: string) {
    Log.i(TAG, orientation)
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

  convertAngle(angle: number) {
    angle = angle % 360;
    Log.i(TAG, `angle ${angle}`);
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
```



