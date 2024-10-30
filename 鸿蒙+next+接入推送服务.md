# 鸿蒙 next 推送服务接入



## 1.开通推送服务

按照官方文档开通推送服务: [https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/push-config-setting-V5](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/push-config-setting-V5)

## 2.配置 client_id

在`entry/src/main/module.json5` 配置新增 `metadata client_id`, 该值在鸿蒙后台AppGallery Connect中找到`常规→应用→Client Id`。

```JavaScript
{
 "module": { 
    "metadata": [
      {
        "name": "client_id",
        "value": "xxxxxxxx"
      }
    ],
 }
}
```



## 3.获取 华为推送 token 并且上报token 到自己的应用服务器

```JavaScript
static async setPushToken() {
    //   关联华为推送 token
    PushMsgUtils.getPushToken((token) => {
      BaseApi.setToken({
        "token": token
      }).then(res => {
        if (res['code'] == 200) {
          LogUtil.info('BaseApi.setToken success');
        }
      })
    })
  }

  static async getPushToken(success: (token: string) => void) {
    pushService.getToken().then((data: string) => {
      success(data)
      LogUtil.info('Succeeded in getting push token:', data);
    }).catch((err: BusinessError) => {
      LogUtil.error(`Failed to get push token: ${err.code} ${err.message}`);
    });
  }
```



## 4.在应用进入首页时申请允许通知权限.

```JavaScript
static requestPermission(context: common.UIAbilityContext) {
    // 申请权限
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      console.info("run isNotificationEnabled success, data: " + data);
      if (!data) {
        notificationManager.requestEnableNotification(context).then(() => {
          console.info(`run requestEnableNotification success`);
        }).catch((err: BusinessError) => {
          if (1600004 == err.code) {
            console.error(
              `run requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
          } else {
            console.error(
              `run requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      }
    }).catch((err: BusinessError) => {
      console.error(`run isNotificationEnabled fail: ${JSON.stringify(err)}`);
    });
  }
```



## 5.新增 skills 配置

在 `entry/src/main/module.json5` 找到启动 Ability 的 skills 配置，`注意默认skills会有一项，千万不要删除，要在尾部添加一条`, actions 设置为空字符串表示不实用actions。

```JavaScript
 {
            "actions": [
              "" 
            ],
            "uris": [
              {
                "scheme": "https",
                "host": "xxx.xxxx.com", //自己的域名
                "path": "test"
              }
            ]
          } // 新增一个skill对象，配置actions和uris用于其他业务场景
```



## 6.测试推送通知可以准确到达用户设备

### 6.1 使用鸿蒙后台的添加推送通知功能:

该功能是测试的后台接口调用推送

![image.png](https://flowus.cn/preview/9fb73b0a-2d3c-4bec-9ab5-b2209b0337c7)



### 6.2 使用设备本地代码推送功能

```JavaScript
// 本地发布普通文本通知
  static localPublishBasic(params: LocalPublishBasicParams) {
    // 通过WantAgentInfo的operationType设置动作类型
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: 'com.xxxxx.xxxx', // 应用包名
          abilityName: 'EntryAbility',
          action: '',
          entities: [],
          uri: "https://xxx.xxxx.com/test",
          parameters: {
            page: params.page,
          }
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
    };

    // 创建WantAgent
    wantAgent.getWantAgent(wantAgentInfo, (err: BusinessError, data: WantAgent) => {
      if (err) {
        console.error(`Failed to get want agent. Code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Succeeded in getting want agent.');
      let notificationRequest: notificationManager.NotificationRequest = {
        id: 1,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 普通文本类型通知
          normal: {
            title: params.title,
            text: params.content,
          },
        },
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        wantAgent: data,
      };

      notificationManager.publish(notificationRequest, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to publish notification. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        console.info('Succeeded in publishing notification.');
      });
    });
  }
```



## 7.处理用户点击推送消息事件

事件会在 Ability 的 `onNewWant` 与 `onCreate`中触发:

```JavaScript
情况1：应用未启动，走 UIAbility 的 onCreate(want: Want)
情况2：应用启动了，在前台或后台，走 UIAbility 的 onNewWant(want: Want)
```



根据以上信息，封装一个统一的消息处理方法:

```JavaScript
interface MessageReceivedParams {
  want?: Want
  method: "onCreate" | "onNewWant" | "enterDnTabBarPage"
}

static messageReceived(params: MessageReceivedParams) {
    if (params.want && params.want.uri && params.want.uri.length > 0) {
      LogUtil.info(`run messageReceived ${params.method}:`, JSON.stringify(params.want))
      const routePae = params.want.parameters?.['page'] as string;
      const proctolObj = Utils.parseProtoclUrl(routePae);
      if (params.method == "onNewWant") {
        // 应用启动了，在前台或后台，走 UIAbility 的 onNewWant(want: Want)
        if (routePae) {
          PushMsgUtils._messageJump(proctolObj)
        } else {
          LogUtil.error("无跳转页面:page传参")
        }

      } else if (params.method == "onCreate") {
        //  应用未启动，走 UIAbility 的 onCreate(want: Want)
        if (routePae) {
          GlobalContext.getContext().setObject("messageReceived", proctolObj)
        }
      }
    }

    if (params.method == "enterDnTabBarPage") {
      // 走onCreate后初始化完成进入DnTabBarPage页
      const messageReceived = GlobalContext.getContext().getObject("messageReceived")
      if (messageReceived) {
        GlobalContext.getContext().deleteObject("messageReceived")
        PushMsgUtils._messageJump(messageReceived as ProctolObjType)
      }
    }
  }
```





## 8.完整代码参考:

将上述逻辑统一封装成了 PushMsgUtils ，根据自己的需求修改使用:



```JavaScript
import { pushService } from '@kit.PushKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common, Want, WantAgent, wantAgent } from '@kit.AbilityKit';
import BaseApi from '../../http/action/BaseApi';
import { router } from '@kit.ArkUI';
import { GlobalContext } from './GlobalContext';
import { LogUtil } from './LogUtil';
import Utils, { ProctolObjType } from './Utils';

interface MessageReceivedParams {
  want?: Want
  method: "onCreate" | "onNewWant" | "enterDnTabBarPage"
}

interface LocalPublishBasicParams {
  page: string // 跳转页面
  title: string // 标题
  content: string // 内容
}

export default class PushMsgUtils {
  static requestPermission(context: common.UIAbilityContext) {
    // 申请权限
    notificationManager.isNotificationEnabled().then((data: boolean) => {
      console.info("run isNotificationEnabled success, data: " + data);
      if (!data) {
        notificationManager.requestEnableNotification(context).then(() => {
          console.info(`run requestEnableNotification success`);
        }).catch((err: BusinessError) => {
          if (1600004 == err.code) {
            console.error(
              `run requestEnableNotification refused, code is ${err.code}, message is ${err.message}`);
          } else {
            console.error(
              `run requestEnableNotification failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      }
    }).catch((err: BusinessError) => {
      console.error(`run isNotificationEnabled fail: ${JSON.stringify(err)}`);
    });
  }

  static async setPushToken() {
    //   关联华为推送 token
    PushMsgUtils.getPushToken((token) => {
      BaseApi.setToken({
        "token": token
      }).then(res => {
        if (res['code'] == 200) {
          LogUtil.info('BaseApi.setToken success');
        }
      })
    })
  }

  static async getPushToken(success: (token: string) => void) {
    pushService.getToken().then((data: string) => {
      success(data)
      LogUtil.info('Succeeded in getting push token:', data);
    }).catch((err: BusinessError) => {
      LogUtil.error(`Failed to get push token: ${err.code} ${err.message}`);
    });
  }


  private static _messageJump(proctolObj: ProctolObjType) {
    let jumpType = parseInt(proctolObj.params['type'] as string)
    if (jumpType == 1) {
      // 跳转应用内页面
      router.pushUrl({
        url: proctolObj.pathName,
        params: proctolObj.params
      })
    } else if (jumpType == 2) {
      //内嵌H5页面
      LogUtil.info("内嵌H5页面")
    } else if (jumpType == 3) {
      // 微信小程序
      const appId = proctolObj.params['appId'] as string;
      LogUtil.info("微信小程序", appId)

    } else if (jumpType == 4) {
      // 浏览器
      Utils.toWebBrowser(proctolObj.originUrl)
    } else if (jumpType == 5) {
      // 打开App或去下载App
      Utils.toAppGalleryDetail("com.qxhms.senioriup")
    } else if (jumpType == 6) {
      // 添加QQ群
    }
  }

  /*
   *参考: https://blog.csdn.net/fwt336/article/details/139465587
   */
  static messageReceived(params: MessageReceivedParams) {
    if (params.want && params.want.uri && params.want.uri.length > 0) {
      LogUtil.info(`run messageReceived ${params.method}:`, JSON.stringify(params.want))
      const routePae = params.want.parameters?.['page'] as string;
      const proctolObj = Utils.parseProtoclUrl(routePae);
      if (params.method == "onNewWant") {
        // 应用启动了，在前台或后台，走 UIAbility 的 onNewWant(want: Want)
        if (routePae) {
          PushMsgUtils._messageJump(proctolObj)
        } else {
          LogUtil.error("无跳转页面:page传参")
        }

      } else if (params.method == "onCreate") {
        //  应用未启动，走 UIAbility 的 onCreate(want: Want)
        if (routePae) {
          GlobalContext.getContext().setObject("messageReceived", proctolObj)
        }
      }
    }

    if (params.method == "enterDnTabBarPage") {
      // 走onCreate后初始化完成进入DnTabBarPage页
      const messageReceived = GlobalContext.getContext().getObject("messageReceived")
      if (messageReceived) {
        GlobalContext.getContext().deleteObject("messageReceived")
        PushMsgUtils._messageJump(messageReceived as ProctolObjType)
      }
    }
  }

  // 本地发布普通文本通知
  static localPublishBasic(params: LocalPublishBasicParams) {
    // 通过WantAgentInfo的operationType设置动作类型
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          deviceId: '',
          bundleName: 'com.xxxx.xxxx',
          abilityName: 'EntryAbility',
          action: '',
          entities: [],
          uri: "https://xxx.xxxx.com/test",
          parameters: {
            page: params.page,
          }
        }
      ],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.CONSTANT_FLAG]
    };

    // 创建WantAgent
    wantAgent.getWantAgent(wantAgentInfo, (err: BusinessError, data: WantAgent) => {
      if (err) {
        console.error(`Failed to get want agent. Code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Succeeded in getting want agent.');
      let notificationRequest: notificationManager.NotificationRequest = {
        id: 1,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT, // 普通文本类型通知
          normal: {
            title: params.title,
            text: params.content,
          },
        },
        notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        wantAgent: data,
      };

      notificationManager.publish(notificationRequest, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to publish notification. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        console.info('Succeeded in publishing notification.');
      });
    });
  }
}



```

