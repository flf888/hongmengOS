# Adding Exam Dates to System Calendar in HarmonyOS Next

## 1. Request Permissions

Add permissions in `entry/src/main/module.json5`. `$string:calendar_reason` is configured in `entry/src/main/resources/string.json`.

```
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.READ_CALENDAR",
        "reason": "$string:calendar_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      },
      {
        "name": "ohos.permission.WRITE_CALENDAR",
        "reason": "$string:calendar_reason",
        "usedScene": {
          "abilities": ["EntryAbility"],
          "when": "inuse"
        }
      }
    ]
  }
}
```

## 2. CalendarUtil Utility Class

Handles calendar operations and permission management:

```
import { calendarManager } from '@kit.CalendarKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, PermissionRequestResult, Permissions, abilityAccessCtrl } from '@kit.AbilityKit';
import Config from '../../http/Config';
import UserCacheManager from './UserCacheManager';
import { JSON } from '@kit.ArkTS';

export class CalendarUtil {
  private static calendarMgr: calendarManager.CalendarManager | null = null;

  // Request calendar permissions
  static requestPermissions(context: Context) {
    const permissions: Permissions[] = [
      'ohos.permission.READ_CALENDAR', 
      'ohos.permission.WRITE_CALENDAR'
    ];
    
    const atManager = abilityAccessCtrl.createAtManager();
    return atManager.requestPermissionsFromUser(context, permissions)
      .then((result: PermissionRequestResult) => {
        console.log(`Permission success: ${JSON.stringify(result)}`);
        CalendarUtil.calendarMgr = calendarManager.getCalendarManager(context);
      })
      .catch((error: BusinessError) => {
        console.error(`Permission error: Code ${error.code}, ${error.message}`);
      });
  }

  // Generate event title
  private static getExamDateTitle() {
    return `${UserCacheManager.getSubjectCatName()} Exam`;
  }

  // Create calendar event object
  private static getExamDateEvent(examDate: string) {
    const date = new Date(examDate);
    const curTime = date.getTime();
    
    return {
      type: calendarManager.EventType.NORMAL,
      title: CalendarUtil.getExamDateTitle(),
      description: `Created by ${Config.app_name}`,
      startTime: curTime,
      endTime: curTime + 24 * 60 * 60 * 1000, // 24 hours
      isAllDay: true,
      reminderTime: [12 * 60] // 12-hour reminder
    } as calendarManager.Event;
  }

  // Add new exam event
  private static addExamDateEvent(calendar: calendarManager.Calendar, examDate: string) {
    const event = CalendarUtil.getExamDateEvent(examDate);
    calendar.addEvent(event)
      .then((eventId: number) => {
        console.info(`Event added successfully. ID: ${eventId}`);
      })
      .catch((err: BusinessError) => {
        console.error(`Add event failed: ${err.code}, ${err.message}`);
      });
  }

  // Update existing event
  private static updateExamDateEvent(calendar: calendarManager.Calendar, 
                                    examDate: string, 
                                    eventId?: number) {
    const event = CalendarUtil.getExamDateEvent(examDate);
    event.id = eventId;
    
    calendar.updateEvent(event)
      .then(() => {
        console.info(`Event updated successfully`);
      })
      .catch((err: BusinessError) => {
        console.error(`Update event failed: ${err.code}, ${err.message}`);
      });
  }

  // Find existing exam events
  private static getExamDateEvents(calendar: calendarManager.Calendar) {
    const filter = calendarManager.EventFilter.filterByTitle(
      CalendarUtil.getExamDateTitle()
    );
    return calendar.getEvents(filter);
  }

  // Main method to add/update exam date
  static addExamDateCalendar(examDate: string) {
    CalendarUtil.calendarMgr?.getCalendar()
      .then((calendar: calendarManager.Calendar) => {
        CalendarUtil.getExamDateEvents(calendar)
          .then((events: calendarManager.Event[]) => {
            if (events?.length > 0) {
              // Update existing event
              CalendarUtil.updateExamDateEvent(calendar, examDate, events[0].id);
            } else {
              // Add new event
              CalendarUtil.addExamDateEvent(calendar, examDate);
            }
          });
      })
      .catch((err: BusinessError) => {
        console.error(`Calendar access failed: ${err.code}, ${err.message}`);
      });
  }
}
```

## 3. Usage Example

Add exam dates to calendar where needed:

```
// Request permissions and add exam date
CalendarUtil.requestPermissions(AppUtil.getContext()).then(() => {
  CalendarUtil.addExamDateCalendar(this.examDate);
});
```

### Key Features:

1. **Permission Management**: Handles runtime permission requests
2. **Event Creation**: Creates all-day exam events with reminders
3. **Conflict Handling**: Updates existing events instead of duplicating
4. **Error Handling**: Comprehensive error logging for all operations
5. **Dynamic Content**: Uses app name and subject name in event details

### Event Properties:

- **Title**: "SubjectName Exam" (e.g., "Mathematics Exam")
- **Description**: "Created by AppName"
- **Duration**: All-day event (24 hours)
- **Reminder**: 12 hours before event
- **Type**: Normal calendar event
