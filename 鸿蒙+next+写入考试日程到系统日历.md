# 鸿蒙 next 写入考试时间日程到系统日历



## 1.获取权限

在`entry/src/main/module.json5`中新增两条申请的权限, `$string:calendar_reason`是在目录`entry/src/main/resources/string.json`中配置。

```JSON
{
  "module":  {
  
  "requestPermissions": [
     
     
     {
        "name" : "ohos.permission.READ_CALENDAR",
        "reason": "$string:calendar_reason",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when":"inuse"
        }
      },
      {
        "name": "ohos.permission.WRITE_CALENDAR",
        "reason": "$string:calendar_reason",
        "usedScene": {
          "abilities": [
            "EntryAbility"
          ],
          "when": "inuse"
        }
      },
 
 ]
  
  
  }

}
```



## 2.封装CalendarUtil工具类来使用日历

```JavaScript
import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, PermissionRequestResult, Permissions, abilityAccessCtrl } from '@kit.AbilityKit';
import Config from '../../http/Config';
import UserCacheManager from './UserCacheManager';
import { JSON } from '@kit.ArkTS';


export class CalendarUtil {
  private static calendarMgr: calendarManager.CalendarManager | null = null;

  static requestPermissions(context: Context) {
    // 注册日历权限, 来自: https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-calendarmanager-V5
    const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
    let atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(context, permissions).then((result: PermissionRequestResult) => {
      console.log(`get Permission success, result: ${JSON.stringify(result)}`);
      CalendarUtil.calendarMgr = calendarManager.getCalendarManager(context);
    }).catch((error: BusinessError) => {
      console.error(`get Permission error, error. Code: ${error.code}, message: ${error.message}`);
    })
  }

  private static getExamDateTitle() {
    return UserCacheManager.getSubjectCatName() + '考试';
  }

  private static getExamDateEvent(examDate: string) {
    const date = new Date(examDate);
    const curTime = date.getTime();
    const event: calendarManager.Event = {
      type: calendarManager.EventType.NORMAL,
      title: CalendarUtil.getExamDateTitle(),
      description: `由${Config.app_name}应用创建日程`,
      startTime: curTime,
      endTime: curTime + 24 * 60 * 60 * 1000,
      isAllDay: true,
      reminderTime: [12 * 60]
    };
    console.log('run getExamDateEvent', JSON.stringify(event))
    return event;
  }

  // 创建考试日程
  private static addExamDateEvent(calendar: calendarManager.Calendar, examDate: string) {
    const event = CalendarUtil.getExamDateEvent(examDate);
    calendar.addEvent(event).then((data: number) => {
      console.info(`Succeeded in adding event, id -> ${data}`);
    }).catch((err: BusinessError) => {
      console.error(`Failed to addEvent. Code: ${err.code}, message: ${err.message}`);
    });
  }

  // 更新考试日程
  private static updateExamDateEvent(calendar: calendarManager.Calendar, examDate: string, eventId?: number) {
    const oriEvent = CalendarUtil.getExamDateEvent(examDate);
    oriEvent.id = eventId;
    calendar.updateEvent(oriEvent).then(() => {
      console.info(`Succeeded in updating event`);
    }).catch((err: BusinessError) => {
      console.error(`Failed to update event. Code: ${err.code}, message: ${err.message}`);
    });
  }

  // 查询考试日程
  private static getExamDateEvents(calendar: calendarManager.Calendar) {
    const filter = calendarManager.EventFilter.filterByTitle(CalendarUtil.getExamDateTitle());
    return calendar.getEvents(filter)
  }

  // 添加考试时间为日历日程
  static addExamDateCalendar(examDate: string) {

    CalendarUtil.calendarMgr?.getCalendar().then((calendar: calendarManager.Calendar) => {
      console.info(`Succeeded in getting calendar -> ${JSON.stringify(calendar)}`);
      CalendarUtil.getExamDateEvents(calendar).then((data: calendarManager.Event[]) => {
        if (data && data.length > 0) {
          // 已经存在该日程则更新
          console.log('run getEvents', JSON.stringify(data))
          CalendarUtil.updateExamDateEvent(calendar, examDate, data[0].id)
        } else {
          // 没有日程则添加
          CalendarUtil.addExamDateEvent(calendar, examDate)
        }
      });


    }).catch((err: BusinessError) => {
      console.error(`Failed to get calendar. Code: ${err.code}, message: ${err.message}`);
    });
  }
}
```



## 3.在需要写入日历的代码位置使用一下代码

```JavaScript
 CalendarUtil.requestPermissions(AppUtil.getContext()).then(() => {
          CalendarUtil.addExamDateCalendar(this.examDate);
        })
```



