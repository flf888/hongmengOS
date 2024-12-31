import { LogUtil } from './LogUtil';
import { BusinessError } from '@ohos.base';
import { KeyboardAvoidMode, window } from '@kit.ArkUI';

import { common } from '@kit.AbilityKit';

interface ImmersionBarSettings {
  transparentStatusBar?: boolean,
  statusBarColor?: string,
  statusBarContentColor?: string,
  navigationBarColor?: string,
  navigationBarContentColor?: string,
  fullScreen?: boolean,
}

export class AppUtil {
  private constructor() {
  }

  private static context: common.UIAbilityContext; //common.UIAbilityContext，上下文


  /**
   * 初始化方法,缓存全局变量，在UIAbility的onCreate方法中初始化该方法。
   * @param windowStage 窗口管理器
   */
  static init(context: common.UIAbilityContext) {
    AppUtil.context = context;
  }


  /**
   * 获取上下文，common.UIAbilityContext
   * @returns
   */
  static getContext(): common.UIAbilityContext {
    if (!AppUtil.context) {
      AppUtil.context = getContext() as common.UIAbilityContext; //兜底
      LogUtil.error("context为空，请在UIAbility的onWindowStageCreate方法中调用AppUtil的init方法初始化！");
    }
    return AppUtil.context;
  }

  /**
   * 获取WindowStage
   * @returns
   */
  static getWindowStage(): window.WindowStage {
    return AppUtil.getContext().windowStage;
  }

  /**
   * 获取主窗口
   */
  static getMainWindow(): window.Window {
    return AppUtil.getContext().windowStage.getMainWindowSync();
  }

  /**
   * 获取UIContext
   * @returns
   */
  static getUIContext(): UIContext {
    return AppUtil.getMainWindow().getUIContext();
  }

  /**
   * 获取状态栏的高度，单位为vp。
   * @returns
   */
  static getStatusBarHeight(): number {
    try {
      let windowClass = AppUtil.getMainWindow();
      let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const height = avoidArea.topRect.height; // 单位 px
      return AppUtil.px2vp(height);
    } catch (err) {
      LogUtil.error(JSON.stringify(err));
      return 0;
    }
  }

  /**
   * 获取底部导航条的高度，单位为vp。
   * @returns
   */
  static getNavigationIndicatorHeight(): number {
    try {
      let windowClass = AppUtil.getMainWindow();
      let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const height = avoidArea.bottomRect.height; // 单位 px
      return AppUtil.px2vp(height);
    } catch (err) {
      LogUtil.error(JSON.stringify(err));
      return 0;
    }
  }


  static setStatusBar(sysBarProps?: window.SystemBarProperties) {
    let windowClass = AppUtil.getMainWindow();
    // 开启沉浸式布局
    windowClass.setWindowLayoutFullScreen(true).then(() => {
      windowClass.setWindowBackgroundColor('#FFFFFF');
    }).catch((error: BusinessError) => {
      LogUtil.error(`setWindowLayoutFullScreen-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    });

    if (sysBarProps) {
      windowClass.setWindowSystemBarProperties(sysBarProps).catch((error: BusinessError) => {
        LogUtil.error(`setWindowSystemBarProperties-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      });
    }
  }

  static setStatusBackground(bgColor= '#fff7f8fb') {
    let windowClass = AppUtil.getMainWindow();
    windowClass.setWindowSystemBarProperties({
      statusBarColor: bgColor
    });
  }

  static px2vp(px: number) {
    let uiContext = AppUtil.getUIContext()
    return uiContext.px2vp(px);
  }
}