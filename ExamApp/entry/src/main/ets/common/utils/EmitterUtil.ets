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