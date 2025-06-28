# HarmonyOS Next: Adding Push Notifications to Atomic Services

## Official Documentation

- **Atomic Service Push**: https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-push-development-V5
- **Subscription Template Setup**: https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/push-as-service-noti-V5

------

## Key Differences from App Push

Atomic services require additional configuration in **AppGallery Connect**:

1. **Subscription Templates**: Define notification templates via the [official guide](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/push-as-service-noti-V5).

------

## Code Implementation

### 1. `PushMsgUtils` Class

```
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { serviceNotification } from '@kit.PushKit';
import { AppUtil } from './AppUtil';
import { LogUtil } from './LogUtil';
import { Want } from '@kit.AbilityKit';
import { AdUtils } from './AdUtils';
import { GlobalContext } from './GlobalContext';

interface MessageReceivedParams {
  want?: Want;
  method: "onCreate" | "onNewWant" | "enterDnTabBarPage";
}

export default class PushMsgUtils {
  /**
   * Request subscription to notification templates.
   * Replace `entityIds` with your actual template IDs.
   */
  static async requestSubscribeNotification() {
    try {
      LogUtil.info("Running requestSubscribeNotification...");
      const entityIds: string[] = ['13B6000E24008000', '13B90C82D3802680'];
      const type: serviceNotification.SubscribeNotificationType =
        serviceNotification.SubscribeNotificationType.SUBSCRIBE_WITH_HUAWEI_ID;
      
      const res: serviceNotification.RequestResult = await serviceNotification.requestSubscribeNotification(
        AppUtil.getContext(),
        entityIds,
        type
      );
      LogUtil.info(`Subscription succeeded: ${JSON.stringify(res.entityResult)}`);
    } catch (err) {
      const e: BusinessError = err as BusinessError;
      LogUtil.error(`Subscription failed: ${e.code} ${e.message}`);
    }
  }

  /**
   * Handle incoming push notifications.
   * @param params - Message context (`onCreate`, `onNewWant`, or `enterDnTabBarPage`).
   */
  static messageReceived(params: MessageReceivedParams) {
    if (params.want?.uri) {
      LogUtil.info(`Message received (${params.method}):`, JSON.stringify(params.want));

      // Extract target page from message data
      const routePage = params.want.parameters?.['page'] as string;

      if (params.method === "onNewWant") {
        // App is running (foreground/background)
        if (routePage) AdUtils.adClickJump(routePage);
        else LogUtil.error("Missing 'page' parameter for navigation");
      } else if (params.method === "onCreate") {
        // App is launching (cold start)
        if (routePage) 
          GlobalContext.getContext().setObject("messageReceived", routePage);
      }
    }

    if (params.method === "enterDnTabBarPage") {
      // Navigate after app initialization
      const routePage = GlobalContext.getContext().getObject("messageReceived") as string;
      if (routePage) {
        GlobalContext.getContext().deleteObject("messageReceived");
        AdUtils.adClickJump(routePage);
      }
    }
  }
}
```

------

## Workflow Summary

1. **Request Subscription**: Call `PushMsgUtils.requestSubscribeNotification()` on app launch.

2. 

   Handle Messages

   :

   - Use `onCreate()` to handle cold starts.
   - Use `onNewWant()` to handle foreground/background notifications.
   - Use `enterDnTabBarPage()` to navigate after initialization.

------

## Key Notes

- **Template ID**: Replace `entityIds` in `requestSubscribeNotification()` with your actual subscription template IDs from AppGallery Connect.
- **Navigation**: The `routePage` parameter in messages determines the target UI page.
- **Context Management**: Use `GlobalContext` to persist navigation data across lifecycle events.

Let me know if you need further refinements!
