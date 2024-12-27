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