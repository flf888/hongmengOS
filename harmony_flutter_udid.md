# HarmonyOS next之harmony_flutter 获取udid



UDID说明：在恢复出厂设置后，UDID（唯一设备标识符）可能会发生变化！另外，如果设备通过OTA（在线更新）升级到了Android 8.0，并且应用程序被重新安装了，由于Android 8.0的安全性更改，UDID也可能会改变。对于已经获取root权限或越狱的设备，其ID是可以被更改的，请注意这一点。不过，由于ID的复杂性，通过随机猜测来冒充另一个已存在的用户应该是不可能实现的。



####  ohos端建立通道获取系统udid

```
import identifier from '@ohos.identifier.oaid';//获取odid库

export default class FlutterUdidPlugin implements MethodCallHandler, FlutterPlugin {
  private channel: MethodChannel | null = null
  private applicationContext: common.Context | null = null
  private ability: UIAbility | null = null;

  constructor(context?: common.Context) {
    if (context) {
      this.applicationContext = context;
    }
  }

  static registerWith(): void {
  }

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.onAttachedToEngine1(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  private onAttachedToEngine1(applicationContext: Context, messenger: BinaryMessenger) {
    this.applicationContext = applicationContext;
    this.channel = new MethodChannel(messenger, "flutter_udid")
    this.channel.setMethodCallHandler(this)
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.ability = binding.getAbility()
  }

  onDetachedFromAbility(): void {
    this.ability = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getUDID") {
      this.requestPermissions().then((data: boolean) => {
        this.getUDID().then((udid: string | null) => {
          if (udid == null || udid == "") {
            result.error("UNAVAILABLE", "UDID not available.", null)
          } else {
          	//传递到flutter层
            result.success(udid)
          }
        })
      })
    } else {
      result.notImplemented()
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = null;
    this.channel?.setMethodCallHandler(null)
  }

  //ohos端获取oaid
  private async getUDID(): Promise<string | null> {
    try {
      return await identifier.getOAID()
    } catch (err) {
      return null
    }
  }

  private async requestPermissions(): Promise<boolean> {
    if (!this.ability) {
      Log.i(TAG, "Could not launch BarcodeScanner because the plugin is not attached to any ability")
      return false
    }
    try {
      const results = await requestPermissions(this.ability!.context)
      return results ? results : false
    } catch (e) {
    }
    return false
  }
}
```





#### flutter端代码

```

class FlutterUdid {
  //建立通道
  static const MethodChannel _channel = const MethodChannel('flutter_udid');

  /// Returns the UDID in the platform-specific format.
  /// iOS: 7946DA4E-8429-423C-B405-B3FC77914E3E,
  /// Android: 8af8770a27cfd182
  static Future<String> get udid async {
    final String udid = await _channel.invokeMethod('getUDID');
    return udid;
  }

  /// Returns the UDID in a consistent format for all platforms.
  /// Example: 984725b6c4f55963cc52fca0f943f9a8060b1c71900d542c79669b6dc718a64b
  static Future<String> get consistentUdid async {
    final String udid = await _channel.invokeMethod('getUDID');
    var bytes = utf8.encode(udid);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
```



### flutter example 引用

```
import 'package:flutter_udid/flutter_udid.dart';

String udid = await FlutterUdid.udid;
```

