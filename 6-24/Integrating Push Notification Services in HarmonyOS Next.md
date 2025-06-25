# Integrating Push Notification Services in HarmonyOS Next

## 1. Enable Push Service

Follow the official documentation to enable push services:
[HarmonyOS Push Configuration Guide](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/push-config-setting-V5)

## 2. Configure Client ID

Add metadata in `entry/src/main/module.json5` using the Client ID from AppGallery Connect (General → App → Client ID):

```
{
  "module": { 
    "metadata": [
      {
        "name": "client_id",
        "value": "xxxxxxxx"
      }
    ]
  }
}
```

## 3. Obtain and Upload Push Token

```
static async setPushToken() {
  PushMsgUtils.getPushToken((token) => {
    BaseApi.setToken({ "token": token }).then(res => {
      if (res['code'] == 200) {
        LogUtil.info('Push token uploaded successfully');
      }
    })
  })
}

static async getPushToken(success: (token: string) => void) {
  pushService.getToken().then((data: string) => {
    success(data);
    LogUtil.info('Push token obtained:', data);
  }).catch((err: BusinessError) => {
    LogUtil.error(`Token retrieval failed: ${err.code} ${err.message}`);
  });
}
```

## 4. Request Notification Permission

Add this during app initialization:

```
static requestPermission(context: common.UIAbilityContext) {
  notificationManager.isNotificationEnabled().then((enabled: boolean) => {
    if (!enabled) {
      notificationManager.requestEnableNotification(context).catch((err: BusinessError) => {
        if (err.code === 1600004) {
          LogUtil.error('Notification permission denied');
        }
      });
    }
  });
}
```

## 5. Configure Deep Linking

Add a new skill configuration in `entry/src/main/module.json5`:

```
{
  "skills": [
    // Existing skills...,
    {
      "actions": [""],
      "uris": [
        {
          "scheme": "https",
          "host": "yourdomain.com",
          "path": "test"
        }
      ]
    }
  ]
}
```

## 6. Test Push Notifications

### 6.1 Using AppGallery Console

### 6.2 Local Test Notification

```
static localPublishBasic(params: LocalPublishBasicParams) {
  const wantAgentInfo: wantAgent.WantAgentInfo = {
    wants: [{
      bundleName: 'com.your.app',
      abilityName: 'EntryAbility',
      uri: "https://yourdomain.com/test",
      parameters: { page: params.page }
    }],
    operationType: wantAgent.OperationType.START_ABILITY
  };

  wantAgent.getWantAgent(wantAgentInfo, (err, agent) => {
    const notification: notificationManager.NotificationRequest = {
      content: {
        normal: { title: params.title, text: params.content }
      },
      wantAgent: agent
    };
    notificationManager.publish(notification);
  });
}
```

## 7. Handle Notification Clicks

```
static messageReceived(params: MessageReceivedParams) {
  if (params.want?.uri) {
    const routePage = params.want.parameters?.['page'] as string;
    const protocolObj = Utils.parseProtoclUrl(routePage);
    
    if (params.method === "onNewWant") {
      // App in foreground/background
      this._handleDeepLink(protocolObj);
    } 
    else if (params.method === "onCreate") {
      // App launched from closed state
      GlobalContext.setObject("deepLinkData", protocolObj);
    }
  }
  
  if (params.method === "enterMainPage") {
    // Handle deferred deep linking
    const data = GlobalContext.getObject("deepLinkData");
    if (data) this._handleDeepLink(data as ProtocolObjType);
  }
}

private static _handleDeepLink(protocolObj: ProtocolObjType) {
  switch (protocolObj.params['type']) {
    case '1': // In-app navigation
      router.pushUrl({ url: protocolObj.pathName });
      break;
    case '4': // External browser
      Utils.openBrowser(protocolObj.originUrl);
      break;
    // Handle other types...
  }
}
```

## 8. Complete PushMsgUtils Implementation

```
import { pushService, notificationManager } from '@kit.PushKit';
import { BusinessError, common, Want, WantAgent, wantAgent } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';
import { GlobalContext } from './GlobalContext';
import { LogUtil } from './LogUtil';
import Utils, { ProtocolObjType } from './Utils';

interface MessageReceivedParams {
  want?: Want;
  method: "onCreate" | "onNewWant" | "enterMainPage";
}

interface LocalPublishBasicParams {
  page: string; // Deep link target
  title: string; // Notification title
  content: string; // Notification content
}

export default class PushMsgUtils {
  // [Previous methods implementation...]

  static messageReceived(params: MessageReceivedParams) {
    if (params.want?.uri) {
      const routePage = params.want.parameters?.['page'] as string;
      const protocolObj = Utils.parseProtoclUrl(routePage);
      
      if (params.method === "onNewWant") {
        this._handleDeepLink(protocolObj);
      } 
      else if (params.method === "onCreate") {
        GlobalContext.setObject("deepLinkData", protocolObj);
      }
    }
    
    if (params.method === "enterMainPage") {
      const data = GlobalContext.getObject("deepLinkData");
      if (data) {
        GlobalContext.deleteObject("deepLinkData");
        this._handleDeepLink(data as ProtocolObjType);
      }
    }
  }

  private static _handleDeepLink(protocolObj: ProtocolObjType) {
    const linkType = parseInt(protocolObj.params['type'] as string);
    switch (linkType) {
      case 1: // In-app screen
        router.pushUrl({ 
          url: protocolObj.pathName,
          params: protocolObj.params
        });
        break;
      case 4: // External URL
        Utils.openBrowser(protocolObj.originUrl);
        break;
      case 5: // App Gallery
        Utils.openAppGallery("com.your.appid");
        break;
      // Additional cases...
    }
  }
}
```

### Key Features:

1. **Token Management**: Automatic token retrieval and server registration
2. **Permission Handling**: Runtime notification permission requests
3. **Deep Linking**: Custom URI schemes for in-app navigation
4. **Notification Handling**: Unified approach for cold/warm starts
5. **Testing Tools**: Both remote and local notification testing
6. **Error Handling**: Comprehensive error logging for all operations

### Implementation Notes:

- Replace placeholder values (`yourdomain.com`, `com.your.app`) with actual app information
- Customize deep link handling according to your app's navigation structure
- Add analytics to track notification delivery and engagement
- Implement proper error handling for network requests
- Test all scenarios (app closed, background, foreground)
