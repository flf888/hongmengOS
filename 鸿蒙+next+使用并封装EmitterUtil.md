

# 鸿蒙 next 使用并封装EmitterUtil

在一些场景中需要进行跨页面或跨组件的事件通信，那么就可以用使用 `Emitter`,官方文档为:[https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/itc-with-emitter-V5](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/itc-with-emitter-V5)。 下面对其进行封装让其方便好用:



## EmitterUtil

```JavaScript
import { emitter } from '@kit.BasicServicesKit';


type EmitterEventId = "parentShowNext" | "parentShowPrevious"

export class EmitterUtil {
  private constructor() {
  }

  /**
   * 发送事件
   */
  static post(eventId: EmitterEventId, data?: Object, priority: emitter.EventPriority = emitter.EventPriority.HIGH) {
    let eventData: emitter.EventData = { data: { "eventData": data } };
    let options: emitter.Options = { priority: priority };
    emitter.emit(eventId, options, eventData);
  }


  /**
   * 订阅事件
   */
  static onSubscribe(eventId: EmitterEventId, callback: (data?: Object) => void) {
    emitter.on(eventId, (eventData: emitter.EventData) => {
      callback(eventData.data?.eventData);
    });
  }


  /**
   * 单次订阅指定事件
   */
  static onceSubscribe(eventId: EmitterEventId, callback: (data?: Object) => void) {
    emitter.once(eventId, (eventData: emitter.EventData) => {
      callback(eventData.data?.eventData);
    });
  }


  /**
   * 取消事件订阅
   */
  static unSubscribe(eventId: EmitterEventId) {
    emitter.off(eventId);
  }
}
```



上方代码中的 `EmitterEventId` ，可以定义自己的事件集合，因为在项目中事件 id 是有限的，定义该类型可以更好的代码提示，防止输错。



