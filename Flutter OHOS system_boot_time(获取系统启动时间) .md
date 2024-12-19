# system_boot_time

获取系统启动时间

## 用法

    import 'package:system_boot_time/system_boot_time.dart';


    final second = await SystemBootTime().second();
  
  

#### 鸿蒙OS代码

### 获取启动时间

           setup(binaryMessenger: BinaryMessenger, api: SystemBootTime | null): void {
    {
      let channel = new BasicMessageChannel<Object>(
    binaryMessenger, "dev.flutter.pigeon.SystemBootTime.second", this.getCodec());
      if (api != null) {
    channel.setMessageHandler({
      onMessage(msg: Object, reply: Reply<Object>): void {
    let wrapped = new Map<string, string | number | Map<string, string | number>>();
    try {
      let systemBootTime = api.second();
      wrapped.set("result", systemBootTime);
    } catch (exception) {
      let errorMap = new Map<string, string | number>();
      errorMap.set("message", exception.message);
      errorMap.set("code", exception.name);
      errorMap.set("details", `Cause: ${exception.cause}, Stacktrace: ${exception.stack}`);
      wrapped.set("error", errorMap);
    }
    reply.reply(wrapped);
      }
    });
      } else {
    channel.setMessageHandler(null);
      }
    }
      }


### 类型转换

          second(): number {
    return Math.floor(systemDateTime.getUptime(systemDateTime.TimeType.STARTUP, false) / 1000);
      }
