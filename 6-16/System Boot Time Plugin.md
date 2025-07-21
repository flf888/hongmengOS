# System Boot Time Plugin

After the smartphone operating system, Huawei has now developed its first computer-dedicated software called HarmonyOS PC, which has a faster boot time than Windows and macOS. At the same time, it offers enhanced fluency in performance.

Boot time or boot speed refers to the startup time of a device. It indicates how long it takes for the device (smartphone, tablet, or laptop) to turn on and load the operating system after being powered on or restarted.

HarmonyOS PC features reveal that it takes only a second or even less in boot time compared to Windows and macOS. It can be used immediately, right after turning it on. You don’t have to wait for a minute or two to begin your operations.

This is one of the biggest benefits of HarmonyOS PCs over other laptops. A faster boot time can improve the user experience, increase efficiency, and potential battery savings. One can access the device and apps more swiftly than ever before.

On the other hand, the HarmonyOS PC beats Windows in terms of fluency. It redefines the level of smoothness of the user experience while interacting with the device.

It shows how effortlessly a tablet, PC, or phone performs tasks, transitions between apps, and responds to user inputs. HarmonyOS PC has secured good grades in both smoothness and boot time against its foreign rivals.

These enhancements are possible due to the removal of C and D disks from the PC. It only runs on local storage and cloud disk, making it lightweight and easier to use.

HarmonyOS PC further auto-optimizes the computer content and cleans up the trash from the bottom. Thus, you won’t require any new system optimizations or acceleration tools. It has an Android tablet-like file setup that manages files and allows quick access to the stored data.

Inputs reveal that HarmonyOS PC has an EROFS high-performance read-only compression file system that enhances random and read performance by 300% and saves 1.6GB of storage compared to EXT

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

