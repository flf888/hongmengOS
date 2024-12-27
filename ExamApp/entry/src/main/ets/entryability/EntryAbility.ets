import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, display } from '@kit.ArkUI';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import { AppUtil } from '../common/utils/AppUtil';
import { AppLinkingUtils } from '../common/utils/AppLinkingUtils';

export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window
  private curBp: string = ''

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    AppUtil.init(this.context)

    AppLinkingUtils.messageReceived({
      want: want,
      method: "onCreate"
    })
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    if (want?.parameters?.formID) {
      PreferencesUtil.putSync('formID', want.parameters.formID + '')
    }
    console.log('调试onNewWant', JSON.stringify(want.parameters))
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    console.log('调试onWindowStageCreate')
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.getMainWindow().then((windowObj) => {
      console.log('run getMainWindow')
      this.windowObj = windowObj
      // 获取应用启动时的窗口尺寸
      this.updateBreakpoint(windowObj.getWindowProperties().windowRect.width)
      // 注册回调函数，监听窗口尺寸变化
      windowObj.on('windowSizeChange', (windowSize) => {
        this.updateBreakpoint(windowSize.width)
      })
    });

    windowStage.loadContent('pages/Splash', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    console.log('调试onForeground')
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');

  }

  onBackground(): void {
    console.log('调试onBackground')
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }


  // 根据当前窗口尺寸更新断点
  private updateBreakpoint(windowWidth: number): void {
    // 拿到当前窗口对象获取当前所在displayId 会在真机平板中报错
    // let displayId = this.windowObj?.getWindowProperties().displayId
    try {
      // 将长度的单位由px换算为vp
      // let windowWidthVp = windowWidth / display.getDisplayByIdSync(displayId).densityPixels
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels

      // console.log('run windowWidthVp', windowWidthVp)
      console.log('run get windowWidthVp', windowWidthVp)
      let newBp: string = ''
      if (windowWidthVp < 600) {
        newBp = 'sm'
      } else if (windowWidthVp < 840) { // 840
        newBp = 'md'
      } else {
        newBp = 'lg'
      }

      if (this.curBp !== newBp) {
        this.curBp = newBp
        // 使用状态变量记录当前断点值
        AppStorage.setOrCreate('currentBreakpoint', this.curBp)
      }
    } catch (err) {
      console.log("getDisplayByIdSync failed err" + err.code)
    }
  }
}
