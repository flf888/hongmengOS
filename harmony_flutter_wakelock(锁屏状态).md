# harmony_flutter_wakelock(锁屏状态)

### 一.MethodChannel

1.flutter端代码

- 创建MethodChannel

  ```
  **static** WakelockPlatformInterface _instance = MethodChannelWakelock();
  ```

  

- 接收ohos端传递过来的状态值

```
import 'dart:async';
import 'dart:typed_data' show Uint8List, Int32List, Int64List, Float64List;

import 'package:flutter/foundation.dart' show WriteBuffer, ReadBuffer;
import 'package:flutter/services.dart';

class ToggleMessage {
  bool? enable;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['enable'] = enable;
    return pigeonMap;
  }

  static ToggleMessage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return ToggleMessage()..enable = pigeonMap['enable'] as bool?;
  }
}

class IsEnabledMessage {
  bool? enabled;

  Object encode() {
    final Map<Object?, Object?> pigeonMap = <Object?, Object?>{};
    pigeonMap['enabled'] = enabled;
    return pigeonMap;
  }

  static IsEnabledMessage decode(Object message) {
    final Map<Object?, Object?> pigeonMap = message as Map<Object?, Object?>;
    return IsEnabledMessage()..enabled = pigeonMap['enabled'] as bool?;
  }
}

class _WakelockApiCodec extends StandardMessageCodec {
  const _WakelockApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is IsEnabledMessage) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else if (value is ToggleMessage) {
      buffer.putUint8(129);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return IsEnabledMessage.decode(readValue(buffer)!);

      case 129:
        return ToggleMessage.decode(readValue(buffer)!);

      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class WakelockApi {
  /// Constructor for [WakelockApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  WakelockApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _WakelockApiCodec();

  Future<void> toggle(ToggleMessage arg_msg) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.WakelockApi.toggle', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(<Object>[arg_msg]) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return;
    }
  }

  Future<IsEnabledMessage> isEnabled() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.WakelockApi.isEnabled', codec,
        binaryMessenger: _binaryMessenger);
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
        details: null,
      );
    } else if (replyMap['error'] != null) {
      final Map<Object?, Object?> error =
          (replyMap['error'] as Map<Object?, Object?>?)!;
      throw PlatformException(
        code: (error['code'] as String?)!,
        message: error['message'] as String?,
        details: error['details'],
      );
    } else {
      return (replyMap['result'] as IsEnabledMessage?)!;
    }
  }
}
```



2.ohos端代码

- 继承FlutterPlugin实现onAttachedToEngine方法
- 创建MethodChannel实例device_util
- setMethodCallHandler
- 通过result回传参数

```
import AbilityAware from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityAware';
import { AbilityPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';
import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { Messages } from './Messages';
import { Wakelock } from './Wakelock';

const TAG = "WakelockPlugin"

export class WakelockPlugin implements FlutterPlugin, AbilityAware {
  private pluginBinding : FlutterPluginBinding | null = null;
  private wakelock : Wakelock | null = null;

  getUniqueClassName(): string {
    return "WakelockPlugin"
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.wakelock = new Wakelock(binding.getAbility().context);
    if (this.pluginBinding != null) {
      Messages.setup(this.pluginBinding.getBinaryMessenger(), this.wakelock);
    }
  }

  onDetachedFromAbility(): void {
    this.wakelock = null;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = binding;
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.pluginBinding = null;
  }
}
```



通过@ohos.windowr获取相对应得参数实现

```
import { Log, Any } from '@ohos/flutter_ohos';
import { IsEnabledMessage, ToggleMessage } from './Messages';
import common from '@ohos.app.ability.common';
import window from '@ohos.window';

const TAG = "Wakelock.ohos";

export interface WakelockApi {
  toggle(msg: ToggleMessage): Promise<void>;

  isEnabled(): IsEnabledMessage;
}

export class Wakelock implements WakelockApi {
  private enabled: boolean = false;
  context?: common.UIAbilityContext;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  toggle(message: ToggleMessage): Promise<void> {
    if (!this.context) {
      throw new NoAbilityError();
    }
    return new Promise<void>((resolve, reject) => {
      window.getLastWindow(this.context).then((data) => {
        return Promise.resolve(data);
      }).then((windowClass: window.Window) => {
        let isKeepScreenOn: boolean = message.enable as boolean;
        Log.i(TAG, "message=" + message.enable);
        Log.i(TAG, "this.enabled=" + this.enabled);
        Log.i(TAG, "isKeepScreenOn=" + isKeepScreenOn);
        windowClass.setWindowKeepScreenOn(isKeepScreenOn).then(() => {
          Log.i(TAG, "setWindowKeepScreenOn success");
          this.enabled = isKeepScreenOn;
          resolve();
        }).catch((err: Any) => {
          this.enabled = false;
          reject(err);
          Log.e(TAG, "setWindowKeepScreenOn error: " + JSON.stringify(err));
        })
      }).catch((err: Any) => {
        this.enabled = false;
        reject(err);
        Log.i(TAG, "setWindowKeepScreenOn other error: " + JSON.stringify(err));
      })
    })
  }

  isEnabled(): IsEnabledMessage {
    if (this.context == null) {
      throw new NoAbilityError()
    }
    let msg = new IsEnabledMessage();
    msg.enabled = this.enabled;
    return msg;
  }
}

export class NoAbilityError extends Error {
  constructor() {
    super("wakelock requires a foreground Ability.")
  }
}
```
