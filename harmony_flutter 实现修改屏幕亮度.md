# harmony_flutter 实现修改屏幕亮度

####  ohos端建立通

```
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

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), this.channelName)
    this.channel?.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null)
    this.channel = null
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityPluginBinding = binding;
  }

  onDetachedFromAbility(): void {
    this.abilityPluginBinding = null;
    this.mainWindow = null
  }

  getWindow(): void {
    this.mainWindow = FlutterManager.getInstance()
      .getWindowStage(FlutterManager.getInstance().getUIAbility(this.abilityPluginBinding?.getAbility().context))
      .getMainWindowSync();
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    try {
      if (!this.mainWindow) {
        this.getWindow();
      }
      switch (call.method) {
        case "brightness":
          result.success(this.getBrightness());
          break;
        case "setBrightness":
          this.mainWindow?.setWindowBrightness(parseFloat(call.argument("brightness")));
          result.success(null);
          break;
        case "isKeptOn":
          let flags: boolean = this.mainWindow?.getWindowProperties().isKeepScreenOn || false
          result.success(flags);
          break;
        case "keepOn":
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
      Log.e(TAG, "set screen brightness failed");
    }
  }

  getBrightness(): number {
    const brightness = this.mainWindow?.getWindowProperties().brightness;
    if (brightness && brightness >= 0) {
      return brightness
    }
    // 首次未获取到窗口亮度时返回系统设置的亮度
    let result: number;
    try {
      // the application is using the system brightness
      let value = settings.getValueSync(
        this.abilityPluginBinding?.getAbility().context,
        settings.display.SCREEN_BRIGHTNESS_STATUS,
        '100',
        settings.domainName.DEVICE_SHARED
      )
      result = parseFloat(value) / 255;
    } catch (err) {
      result = 1.0;
      Log.e(TAG, "get screen brightness failed");
    }
    return result;
  }
}
```



#### flutter端代码

```
import 'dart:async';

import 'package:flutter/services.dart';

class Screen {
  static const MethodChannel _channel = const MethodChannel('github.com/clovisnicolas/flutter_screen');

  static Future<double> get brightness async => (await _channel.invokeMethod('brightness')) as double;
  static Future setBrightness(double brightness) =>_channel.invokeMethod('setBrightness',{"brightness" : brightness});
  static Future<bool> get isKeptOn async => (await _channel.invokeMethod('isKeptOn')) as bool;
  static Future keepOn(bool on) => _channel.invokeMethod('keepOn', {"on" : on});
}
```



```
class _MyAppState extends State<MyApp> {
  bool _isKeptOn = false;
  double _brightness = 1.0;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  initPlatformState() async {
    bool keptOn = await Screen.isKeptOn;
    double brightness = await Screen.brightness;
    setState((){
      _isKeptOn = keptOn;
      _brightness = brightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(title: new Text('Screen plugin example')),
        body: new Center(
            child: new Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Screen is kept on ? "),
                      new Checkbox(value: _isKeptOn, onChanged: (bool b){
                        Screen.keepOn(b);
                        setState((){_isKeptOn = b; });
                      })
                    ]
                  ),
                  new Text("Brightness :"),
                  new Slider(value : _brightness, onChanged : (double b){
                    setState((){_brightness = b;});
                    Screen.setBrightness(b);
                  })
                ]
            )
        ),
      ),
    );
  }
}
```

### flutter example 引用

```
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
```