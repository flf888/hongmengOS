# System Boot Time Plugin

**Retrieve the system boot time of HarmonyOS devices**

------

## Usage

Import the plugin in your Flutter project:

```
import 'package:system_boot_time/system_boot_time.dart';

final seconds = await SystemBootTime().second();
```

------

## HarmonyOS Code Implementation

### 1. Get System Boot Time

```
// Get the system uptime in seconds since startup
second(): number {
  return Math.floor(
    systemDateTime.getUptime(systemDateTime.TimeType.STARTUP, false) / 1000
  );
}
```

### 2. Message Channel Setup

```
setup(binaryMessenger: BinaryMessenger, api: SystemBootTime | null): void {
  const channel = new BasicMessageChannel<Object>(
    binaryMessenger,
    "dev.flutter.pigeon.SystemBootTime.second",
    this.getCodec()
  );

  if (api != null) {
    channel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
        try {
          // Wrap the result in a map for serialization
          const wrapped: Record<string, unknown> = {
            result: api.second()
          };
          reply.reply(wrapped);
        } catch (exception) {
          // Return error details if an exception occurs
          const errorMap: Record<string, string> = {
            message: exception.message,
            code: exception.name,
            details: `Cause: ${exception.cause}, Stacktrace: ${exception.stack}`
          };
          reply.reply({ error: errorMap });
        }
      }
    });
  } else {
    channel.setMessageHandler(null);
  }
}
```

------

## Key Features

- **Low Overhead**: Retrieves boot time via system APIs without blocking the main thread.
- **Type Safety**: Returns a numeric value representing seconds since system startup.
- **Error Handling**: Provides detailed error messages for debugging.

