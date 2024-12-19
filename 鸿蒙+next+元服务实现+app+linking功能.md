

# 鸿蒙 next 元服务实现 app linking 功能



## 1.前置信息

关于鸿蒙 next元服务的 app linking 官方文档为: [https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-applinking-V5](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-applinking-V5)

- 通过阅读上方的官方文档，那么需要实现两个功能，一个是如果需要跳转指定页面的元服务，那么则需要解析传来的`pagePath`参数，链接与参数是通过 `AppGrallery Connect → App Liking` 中去生成。第二个功能是可以在使用代码根据链接跳转元服务。

- `AppGrallery Connect → App Liking` 生成的链接既可以在程序中使用，也可以在短信链接中使用。



有了上面这些信息就可以实现逻辑，这里封装了一个 `AppLinkingUtils`工具类。



## 2.实现`AppLinkingUtils`工具类

```JavaScript
import { common, Want, wantAgent } from '@kit.AbilityKit';
import { GlobalContext } from './GlobalContext';
import { router } from '@kit.ArkUI';
import { AppUtil } from './AppUtil';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from './LogUtil';

interface MessageReceivedParams {
  want?: Want
  method: "onCreate" | "enterDnTabBarPage"
}

/**
 * 官方文档: https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-applinking-V5
 */
export class AppLinkingUtils {
  static messageReceived(params: MessageReceivedParams) {
    if (params.want) {
      const want = params.want;
      const url = want?.uri;
      const pagePath = want.parameters?.['pagePath'] as string;

      if (pagePath) {
        GlobalContext.getContext().setObject("appLinkingPagePath", pagePath);
      }
    }

    if (params.method == "enterDnTabBarPage") {
      const appLinkingPagePath = GlobalContext.getContext().getObject("appLinkingPagePath") as string;
      if (appLinkingPagePath) {
        GlobalContext.getContext().deleteObject("appLinkingPagePath");
        router.pushUrl({
          url: appLinkingPagePath
        })
      }
    }
  }

  static openLink(url: string) {
    let context: common.UIAbilityContext = AppUtil.getContext();
    // link 可替换成开发者自行配置的元服务链接
    let link = url || "https://hoas.drcn.agconnect.link/9P7g";
    context.openLink(link)
      .then(() => {
        LogUtil.info('openlink success.');
      })
      .catch((error: BusinessError) => {
        LogUtil.error(`openlink failed. error:${JSON.stringify(error)}`);
      });
  }
}
```



## messageReceived的需要在两个地方去调用

### 1.在EntryAbility的onCreate 方法中调用

```JavaScript
export default class EntryAbility extends UIAbility  {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AppUtil.init(this.context)

    AppLinkingUtils.messageReceived({
      want: want,
      method: "onCreate"
    })

  }

}
```



### 2.在完成数据加载进入 tab 首页时调用

```JavaScript
@Preview
@Entry
@Component
struct DnTabBarPage {
  aboutToAppear() {
    
    AppLinkingUtils.messageReceived({
      method: "enterDnTabBarPage"
    })
  }
}
```





