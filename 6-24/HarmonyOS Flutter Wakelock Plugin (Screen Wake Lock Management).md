# HarmonyOS Flutter Wakelock Plugin (Screen Wake Lock Management)

------

## I. MethodChannel Implementation

### 1. Flutter Code Implementation

**Defining the Wakelock API**

```
// Singleton pattern for Wakelock API
static WakelockPlatformInterface _instance = MethodChannelWakelock();

// Message encoding/decoding for Wakelock state
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

// Custom codec for Wakelock messages
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

// Wakelock API interface
class WakelockApi {
  final BinaryMessenger? _binaryMessenger;

  WakelockApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;

  static const MessageCodec<Object?> codec = _WakelockApiCodec();

  // Toggle screen wake lock state
  Future<void> toggle(ToggleMessage arg_msg) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.WakelockApi.toggle',
      codec,
      binaryMessenger: _binaryMessenger,
    );
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
    }
  }

  // Check current wake lock state
  Future<IsEnabledMessage> isEnabled() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
      'dev.flutter.pigeon.WakelockApi.isEnabled',
      codec,
      binaryMessenger: _binaryMessenger,
    );
    final Map<Object?, Object?>? replyMap =
        await channel.send(null) as Map<Object?, Object?>?;
    if (replyMap == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Channel connection failed.',
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

------

### 2. OHOS Code Implementation

**Integrating with Flutter Engine**

```
import { Wakelock } from './Wakelock';
import { AbilityPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/ability/AbilityPluginBinding';

const TAG = "WakelockPlugin";

export class WakelockPlugin implements FlutterPlugin, AbilityAware {
  private pluginBinding: FlutterPluginBinding | null = null;
  private wakelock: Wakelock | null = null;

  getUniqueClassName(): string {
    return "WakelockPlugin";
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

**OHOS Wakelock Logic**

```
import { Log, Any } from '@ohos/flutter_ohos';
import { ToggleMessage, IsEnabledMessage } from './Messages';
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

  async toggle(message: ToggleMessage): Promise<void> {
    if (!this.context) throw new NoAbilityError();
    return new Promise((resolve, reject) => {
      window.getLastWindow(this.context).then((windowInstance) => {
        const isKeepScreenOn = message.enable as boolean;
        Log.i(TAG, `Setting keepScreenOn to ${isKeepScreenOn}`);
        windowInstance.setWindowKeepScreenOn(isKeepScreenOn)
          .then(() => {
            this.enabled = isKeepScreenOn;
            resolve();
          })
          .catch((err: Any) => {
            this.enabled = false;
            reject(err);
            Log.e(TAG, `Error setting wake lock: ${JSON.stringify(err)}`);
          });
      });
    });
  }

  isEnabled(): IsEnabledMessage {
    if (!this.context) throw new NoAbilityError();
    return new IsEnabledMessage()..enabled = this.enabled;
  }
}

export class NoAbilityError extends Error {
  constructor() {
    super("Wakelock requires a foreground Ability context.");
  }
}
```

------

## II. Wakelock Usage Example

### **Enable Wake Lock**

```
// Request screen wake lock
await WakelockApi().toggle(ToggleMessage()..enable = true);
```

### **Check Wake Lock Status**

```
final status = await WakelockApi().isEnabled();
print("Wake lock is ${status.enabled ? 'enabled' : 'disabled'}");
```

------

## III. Key Features

- **Screen Wake Lock Management**: Prevents device screen from dimming or turning off.
- **Cross-Platform Compatibility**: Works with both Flutter and HarmonyOS.
- **Error Handling**: Robust exception handling for edge cases (e.g., no active Ability).

